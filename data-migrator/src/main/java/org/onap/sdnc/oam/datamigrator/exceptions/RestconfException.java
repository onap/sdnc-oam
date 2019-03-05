package org.onap.sdnc.oam.datamigrator.exceptions;

public class RestconfException extends Exception{

    private final int errorCode;
    private final String errorMessage;

    public RestconfException(int errorCode, String errorMessage) {
        super(errorMessage);
        this.errorCode = errorCode;
        this.errorMessage = errorMessage;
    }

    public RestconfException(int errorCode, String errorMessage, Throwable e) {
        super(errorMessage,e);
        this.errorCode = errorCode;
        this.errorMessage = errorMessage;
    }

    public int getErrorCode() {
        return errorCode;
    }

    public String getErrorMessage() {
        return errorMessage;
    }
}
