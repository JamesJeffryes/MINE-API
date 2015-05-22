

function mineDatabaseServices(url, auth, auth_cb) {

    this.url = url;
    var _url = url;
    var deprecationWarningSent = false;

    function deprecationWarning() {
        if (!deprecationWarningSent) {
            deprecationWarningSent = true;
            if (!window.console) return;
            console.log(
                "DEPRECATION WARNING: '*_async' method names will be removed",
                "in a future version. Please use the identical methods without",
                "the'_async' suffix.");
        }
    }

    var _auth = auth ? auth : { 'token' : '', 'user_id' : ''};
    var _auth_cb = auth_cb;


    this.model_search = function (query, _callback, _errorCallback) {
    return json_call_ajax("mineDatabaseServices.model_search",
        [query], 1, _callback, _errorCallback);
};

    this.model_search_async = function (query, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("mineDatabaseServices.model_search", [query], 1, _callback, _error_callback);
    };

    this.quick_search = function (db, query, _callback, _errorCallback) {
    return json_call_ajax("mineDatabaseServices.quick_search",
        [db, query], 1, _callback, _errorCallback);
};

    this.quick_search_async = function (db, query, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("mineDatabaseServices.quick_search", [db, query], 1, _callback, _error_callback);
    };

    this.similarity_search = function (db, comp_structure, min_tc, fp_type, limit, _callback, _errorCallback) {
    return json_call_ajax("mineDatabaseServices.similarity_search",
        [db, comp_structure, min_tc, fp_type, limit], 1, _callback, _errorCallback);
};

    this.similarity_search_async = function (db, comp_structure, min_tc, fp_type, limit, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("mineDatabaseServices.similarity_search", [db, comp_structure, min_tc, fp_type, limit], 1, _callback, _error_callback);
    };

    this.structure_search = function (db, input_format, comp_structure, _callback, _errorCallback) {
    return json_call_ajax("mineDatabaseServices.structure_search",
        [db, input_format, comp_structure], 1, _callback, _errorCallback);
};

    this.structure_search_async = function (db, input_format, comp_structure, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("mineDatabaseServices.structure_search", [db, input_format, comp_structure], 1, _callback, _error_callback);
    };

    this.substructure_search = function (db, substructure, limit, _callback, _errorCallback) {
    return json_call_ajax("mineDatabaseServices.substructure_search",
        [db, substructure, limit], 1, _callback, _errorCallback);
};

    this.substructure_search_async = function (db, substructure, limit, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("mineDatabaseServices.substructure_search", [db, substructure, limit], 1, _callback, _error_callback);
    };

    this.database_query = function (db, mongo_query, _callback, _errorCallback) {
    return json_call_ajax("mineDatabaseServices.database_query",
        [db, mongo_query], 1, _callback, _errorCallback);
};

    this.database_query_async = function (db, mongo_query, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("mineDatabaseServices.database_query", [db, mongo_query], 1, _callback, _error_callback);
    };

    this.get_comps = function (db, ids, _callback, _errorCallback) {
    return json_call_ajax("mineDatabaseServices.get_comps",
        [db, ids], 1, _callback, _errorCallback);
};

    this.get_comps_async = function (db, ids, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("mineDatabaseServices.get_comps", [db, ids], 1, _callback, _error_callback);
    };

    this.get_rxns = function (db, ids, _callback, _errorCallback) {
    return json_call_ajax("mineDatabaseServices.get_rxns",
        [db, ids], 1, _callback, _errorCallback);
};

    this.get_rxns_async = function (db, ids, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("mineDatabaseServices.get_rxns", [db, ids], 1, _callback, _error_callback);
    };

    this.get_ops = function (db, operator_names, _callback, _errorCallback) {
    return json_call_ajax("mineDatabaseServices.get_ops",
        [db, operator_names], 1, _callback, _errorCallback);
};

    this.get_ops_async = function (db, operator_names, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("mineDatabaseServices.get_ops", [db, operator_names], 1, _callback, _error_callback);
    };

    this.get_models = function (_callback, _errorCallback) {
    return json_call_ajax("mineDatabaseServices.get_models",
        [], 1, _callback, _errorCallback);
};

    this.get_models_async = function (_callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("mineDatabaseServices.get_models", [], 1, _callback, _error_callback);
    };

    this.get_adducts = function (_callback, _errorCallback) {
    return json_call_ajax("mineDatabaseServices.get_adducts",
        [], 1, _callback, _errorCallback);
};

    this.get_adducts_async = function (_callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("mineDatabaseServices.get_adducts", [], 1, _callback, _error_callback);
    };

    this.ms_adduct_search = function (text, text_type, ms_params, _callback, _errorCallback) {
    return json_call_ajax("mineDatabaseServices.ms_adduct_search",
        [text, text_type, ms_params], 1, _callback, _errorCallback);
};

    this.ms_adduct_search_async = function (text, text_type, ms_params, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("mineDatabaseServices.ms_adduct_search", [text, text_type, ms_params], 1, _callback, _error_callback);
    };

    this.mz_search = function (text, text_type, mz_params, _callback, _errorCallback) {
    return json_call_ajax("mineDatabaseServices.mz_search",
        [text, text_type, mz_params], 1, _callback, _errorCallback);
};

    this.mz_search_async = function (text, text_type, mz_params, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("mineDatabaseServices.mz_search", [text, text_type, mz_params], 1, _callback, _error_callback);
    };

    this.pathway_search = function (db, start_comp, end_comp, len_limit, all_paths, _callback, _errorCallback) {
    return json_call_ajax("mineDatabaseServices.pathway_search",
        [db, start_comp, end_comp, len_limit, all_paths], 1, _callback, _errorCallback);
};

    this.pathway_search_async = function (db, start_comp, end_comp, len_limit, all_paths, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("mineDatabaseServices.pathway_search", [db, start_comp, end_comp, len_limit, all_paths], 1, _callback, _error_callback);
    };
 

    /*
     * JSON call using jQuery method.
     */
    function json_call_ajax(method, params, numRets, callback, errorCallback) {
        var deferred = $.Deferred();

        if (typeof callback === 'function') {
           deferred.done(callback);
        }

        if (typeof errorCallback === 'function') {
           deferred.fail(errorCallback);
        }

        var rpc = {
            params : params,
            method : method,
            version: "1.1",
            id: String(Math.random()).slice(2),
        };

        var beforeSend = null;
        var token = (_auth_cb && typeof _auth_cb === 'function') ? _auth_cb()
            : (_auth.token ? _auth.token : null);
        if (token != null) {
            beforeSend = function (xhr) {
                xhr.setRequestHeader("Authorization", token);
            }
        }

        var xhr = jQuery.ajax({
            url: _url,
            dataType: "text",
            type: 'POST',
            processData: false,
            data: JSON.stringify(rpc),
            beforeSend: beforeSend,
            success: function (data, status, xhr) {
                var result;
                try {
                    var resp = JSON.parse(data);
                    result = (numRets === 1 ? resp.result[0] : resp.result);
                } catch (err) {
                    deferred.reject({
                        status: 503,
                        error: err,
                        url: _url,
                        resp: data
                    });
                    return;
                }
                deferred.resolve(result);
            },
            error: function (xhr, textStatus, errorThrown) {
                var error;
                if (xhr.responseText) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        error = resp.error;
                    } catch (err) { // Not JSON
                        error = "Unknown error - " + xhr.responseText;
                    }
                } else {
                    error = "Unknown Error";
                }
                deferred.reject({
                    status: 500,
                    error: error
                });
            }
        });

        var promise = deferred.promise();
        promise.xhr = xhr;
        return promise;
    }
}


