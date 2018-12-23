#include "idris_rts.h"

const CData idris_mongoc_client_new_from_uri(const CData uri_cdata);

const int idris_mongoc_error_api_version_legacy();

const int idris_mongoc_error_api_version_2();

const int idris_mongoc_client_set_error_api(const CData client_cdata,
					    const int version);

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
