#include <stdio.h>
#include <string.h>
#include <usb.h>
#include <math.h>

#define LED_VENDOR_ID   0x046d
#define LED_PRODUCT_ID  0x0a0e

static void send_data(struct usb_dev_handle *handle, char *data)
{
    int ret;

    ret = usb_control_msg(handle,
            USB_ENDPOINT_OUT | USB_TYPE_CLASS | USB_RECIP_INTERFACE, // request type
            0x00000009, // request
            0x0200, // value
            0x02, // index
            data,
            0x00000008,
            5000);

    if (ret == -1) {
        fprintf(stderr, "Permission Denied\n");
    } else {
        fprintf(stderr, "usb_control_msg returned %d\n", ret);
    }
}

static struct usb_device *device_init(void)
{
    struct usb_bus *usb_bus;
    struct usb_device *dev;

    usb_init();
    usb_find_busses();
    usb_find_devices();

    for (usb_bus = usb_busses;
         usb_bus;
         usb_bus = usb_bus->next) {
        for (dev = usb_bus->devices;
             dev;
             dev = dev->next) {
            if ((dev->descriptor.idVendor
                  == LED_VENDOR_ID) &&
                (dev->descriptor.idProduct
                  == LED_PRODUCT_ID))
                return dev;
        }
    }
    return NULL;
}

int main(int argc, char **argv)
{
    struct usb_device *usb_dev;
    struct usb_dev_handle *usb_handle;

    usb_dev = device_init();
    if (usb_dev == NULL) {
        fprintf(stderr, "Device not found\n");
        return 1;
    }

    usb_handle = usb_open(usb_dev);
    if (usb_handle == NULL) {
        fprintf(stderr,
             "Not able to claim the USB device\n");
        usb_close(usb_handle);
        return 1;
    }

    if (argc != 8) {
        fprintf(stderr,
                "incorrect number of arguments\n");
        usb_close(usb_handle);
        return 1;
    }

    enum settings {
        PREEM_50 = 0x00,
        PREEM_75 = 0x04,
        STEREO = 0x00,
        MONO = 0x01,
        ENABLE = 0x01,
        DISABLE = 0x2,
        MUTE = 0x04,
        UNMUTE = 0x08,
        FREQ = 0x10
    };

    char conf1[8] = "\x00\x50\x00\x00\x00\x00\x00\x00";
    char conf2[8] = "\x00\x51\x00\x00\x00\x00\x00\x00";

    int ival, ret;
    float fval;

    // get TX
    if (!strcasecmp(argv[1], "-")) {
        conf2[2] = '\x00';
    } else {
        ret = sscanf(argv[1], "%d", &ival);
        if (ret == 1) {
            if (ival >= 0 && ival <= 23) {
                conf2[2] = (ival%6)<<4 | (23-ival)/6;
            } else {
                fprintf(stderr, "TX must be from 0 to 23\n");
                return 1;
            }
        } else {
            fprintf(stderr, "TX must be integer\n");
            return 1;
        }
    }

    // get preemphasis
    if (!strcasecmp(argv[2], "-") || !strcasecmp(argv[2], "50us")) {
        conf2[3] |= PREEM_50;
    } else if (!strcasecmp(argv[2], "75us")) {
        conf2[3] |= PREEM_75;
    } else {
        fprintf(stderr, "preemphasis must be either 50us or 75us\n");
        return 1;
    }

    // get channels
    if (!strcasecmp(argv[3], "-") || !strcasecmp(argv[3], "stereo")) {
        conf2[3] |= STEREO;
    } else if (!strcasecmp(argv[3], "mono")) {
        conf2[3] |= MONO;
    } else {
        fprintf(stderr, "channels must be mono or stereo\n");
        return 1;
    }

    // get frequency
    if (!strcasecmp(argv[4], "-")) {
        fval = 90.0f;
    } else {
        ret = sscanf(argv[4], "%f", &fval);
        if (ret == 1) {
            if (fval < 76.0f || fval > 108.0f) {
                fprintf(stderr, "frequency must be from 76.0 to 108.0\n");
                return 1;
            }
        } else {
            fprintf(stderr, "frequency must be float\n");
            return 1;
        }
    }
    long int ifreq = lround(20.0f*(fval-76.0f));
    conf1[2] = (ifreq >> 8) & 0xff;
    conf1[3] = ifreq & 0xff;

    // get PA
    if (!strcasecmp(argv[5], "-")) {
        conf1[4] = 120;
    } else {
        ret = sscanf(argv[5], "%d", &ival);
        if (ret == 1) {
            if (ival >= 30 && ival <= 120) {
                conf1[4] = ival;
            } else {
                fprintf(stderr, "PA ust be from 30 to 120\n");
                return 1;
            }
        } else {
            fprintf(stderr, "PA must be integer\n");
            return 1;
        }
    }

    // get enable
    if (!strcasecmp(argv[6], "-") || !strcasecmp(argv[6], "enable")) {
        conf1[5] |= ENABLE;
    } else if (!strcasecmp(argv[6], "disable")) {
        conf1[5] |= DISABLE;
    } else {
        fprintf(stderr, "must be enable or disable");
        return 1;
    }

    // get mute
    if (!strcasecmp(argv[7], "-") || !strcasecmp(argv[7], "unmute")) {
        conf1[5] |= UNMUTE;
    } else if (!strcasecmp(argv[7], "mute")) {
        conf1[5] |= MUTE;
    } else {
        fprintf(stderr, "mute must be mute or unmute");
        return 1;
    }
    conf1[5] |= FREQ;

    send_data(usb_handle, conf1);
    send_data(usb_handle, conf2);

    return 0;
}
