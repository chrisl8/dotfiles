/*
The code works, put it somewhere in a file called "leds.c", and then you could compile it using gcc like this:
gcc -o turnLedOn thinkPadLeds.c

Finally, run it using:
sudo ./leds

https://www.reddit.com/r/thinkpad/comments/7n8eyu/thinkpad_led_control_under_gnulinux/
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define _GNU_SOURCE
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/utsname.h>
#define init_module(mod, len, opts) syscall(__NR_init_module, mod, len, opts)
#define delete_module(name, flags) syscall(__NR_delete_module, name, flags)
int main(int argc, char** argv) {
    /* get kernel version */
    struct utsname os;
    uname(&os);
    /* generate path to ec_sys */
    char path[100] = "/lib/modules/";
    strcat(path, os.release);
    strcat(path, "/kernel/drivers/acpi/ec_sys.ko");
    /* unload driver, as we need to make sure it is loaded with write support as well */
    delete_module(path, O_NONBLOCK);
    /* holds info about the kernel module; we need its size, so we can allocate that
    memory on heap, so we load it in memory the same as modprobe does */
    struct stat st;
    /* pointer to kernel module that we open using open syscall */
    int fd;
    /* pointer to area of heap memory that we load the driver into; do not forget to free
    it before exiting the program */
    void *image;
    /* "open" kernel module, get pointer to it */
    fd = open(path, O_RDONLY);
    /* get info about the opened file */
    fstat(fd, &st);
    /* allocate memory as specified by the size of the file */
    image = malloc(st.st_size * sizeof(unsigned char));
    /* read contents of the file of kernel module and put read data into RAM */
    read(fd, image, st.st_size);
    /* close kernel module file */
    close(fd);
    /* finally, load the kernel module into system */
    init_module(image, st.st_size, "write_support=1");
    /* sizeof(unsigned char) returns (evaluates to actually, it is an operator) 1,
    as data of unsigned char type takes up one byte */

    /*
    Now, about that byte that specifies the state of the LEDs: first nibble represents state, and can be:
    0 - off
    8 - on
    c - blink

    Last nibble represents which LED, can be from 0-15, and known ones (on my laptop at least) are:
    0 - power
    6 - Fn Lock
    7 - sleep (I don't have it, but some models do)
    a - red dot on the back
    e - microphone

    Try with other numbers, they should toggle some other LEDs as well. Some are described here: http://www.thinkwiki.org/wiki/Table_of_thinkpad-acpi_LEDs
    */

    size_t seek = 12, data = 0x0a, count = 1, bs = sizeof(unsigned char);
    /* opens the file pointing to the EC, stores a pointer to it in "f" */
    FILE* f = fopen("/sys/kernel/debug/ec/ec0/io", "rb+");
    /* seek the file 12 bytes from the beginning (SEEK_SET), so we get to proper location */
    fseek(f, seek, SEEK_SET);
    /* fwrite takes an argument to a buffer containing the values to be written, but we
    write just one value, so we just pass the address of the regular variable "data" */
    fwrite(&data, bs, count, f);
    /* close file */
    fclose(f);
    /* unload driver from system so that other apps cannot use it, not risking anything */
    delete_module(path, O_NONBLOCK);
    /* free memory used by the contents of the kernel module's file */
    free(image);
    return 0;
}
/* Updated code, replaced system calls with loading the module directly from C code as
described at https://stackoverflow.com/questions/5947286/how-can-linux-kernel-modules-be-loaded-from-c-code
Idea about uname from https://stackoverflow.com/questions/2987592/read-linux-kernel-version-using-c*/
