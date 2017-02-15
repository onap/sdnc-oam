import esGateKeeper.*;
import java.util.*;
import  java.io.*;
import java.net.*;
public class  CSPCheck{

public static void main(String[] args){
        try{
		String attuid = "";	
		if(args != null && args.length == 2){
			String secCookie = args[0];
			//validationEnv can be DEVL or PROD	
			String validationEnv=args[1];
			String retString = esGateKeeper.esGateKeeper(secCookie, "CSP", validationEnv, -5, "/tmp/");
			if(retString != null){
				String[] dataArr = retString.split("\\|");
				attuid= dataArr[5];

			}
			System.out.print("{" + "\"attuid\" : \"" + attuid + "\"}");
		}
	}catch(Exception e){
		System.out.print("{" + "\"attuid\" : \"ERROR\"}");
	}
}
}

