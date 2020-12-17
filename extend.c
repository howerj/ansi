#include "pickle.h"
#include <assert.h>

#define UNUSED(X) ((void)(X))
#define ok(i, ...)    pickle_result_set(i, PICKLE_OK,    __VA_ARGS__)
#define error(i, ...) pickle_result_set(i, PICKLE_ERROR, __VA_ARGS__)

/* TODO:
 * - Add commands for "sleep"
 * - Read character from console (immediate, uncooked mode)
 */

int pickleCommandSleep(pickle_t *i, int argc, char **argv, void *privdata) {
	UNUSED(privdata);
	if (argc != 2)
		return error(i, "Invalid command %s -- expected {number}", argv[0]);
	return PICKLE_OK;
}

int pickleCommandKey(pickle_t *i, int argc, char **argv, void *privdata) {
	UNUSED(privdata);
	if (argc != 1)
		return error(i, "Invalid command %s -- expected (nil)", argv[0]);
	return PICKLE_OK;
}

int pickle_extend(pickle_t *i) {
	assert(i);
	if (pickle_command_register(i, "sleep", pickleCommandSleep, NULL) != PICKLE_OK) return PICKLE_ERROR;
	if (pickle_command_register(i, "key",   pickleCommandKey,   NULL) != PICKLE_OK) return PICKLE_ERROR;
	return PICKLE_OK;
}

