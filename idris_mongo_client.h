#include "idris_rts.h"

CData idris_mongoc_client_new_from_uri(const CData uri);

int idris_mongoc_client_set_appname(const CData client,
				    const char * appname);

CData idris_mongoc_client_get_database(const CData clientCData,
				       const char * name);

CData idris_mongoc_client_command_simple(const CData client_cdata,
                                         const char * db_name,
                                         const CData command_cdata);

CData idris_mongoc_client_write_command_with_opts(const CData client_cdata,
						  const char * db_name,
						  const CData command_cdata,
						  const CData options_cdata);
