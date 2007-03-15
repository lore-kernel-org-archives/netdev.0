From: Marc.Obbad@smsc.com
Subject: Re: [Bridge] rstp for 2.4 kernel: port state keeps changing
Date: Thu, 15 Mar 2007 13:10:00 -0400
Message-ID: <OF2B235CAE.4C560998-ON8525729F.005E1121-8525729F.005E4D58@smsc.com>
References: <45F8E00A.7050908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: bridge@linux-foundation.org, bridge-bounces@lists.osdl.org,
	netdev@vger.kernel.org
To: ptiwatthanont@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1847 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1422975AbXCORKT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2007 13:10:19 -0400
In-Reply-To: <45F8E00A.7050908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For me, I ma building for Embedded platform.
Go to Directory where the Makefile is and do this:


make -C  $LINUX_DIR  SUBDIRS=$PWD  modules
LINUX_DIR should point to LINUX directory

LINUX_DIR=/home/swdev/PPC/linux/   as example

-Marc.



                                                                                                                        
             Pasakorn Tiwatthanont                                                                                      
             <ptiwatthanont@gmail.com>                                                                                  
             Sent by:                                                                                                To 
             bridge-bounces@lists.osdl.org               Marc Obbad/SMSC@SMSC                                           
                                                                                                                     cc 
                                                         bridge-bounces@lists.osdl.org, bridge@linux-foundation.org,    
             03/15/2007 01:56 AM                         netdev@vger.kernel.org                                         
                                                                                                                Subject 
                                                         Re: [Bridge] rstp for 2.4 kernel: port state keeps changing    
                      Please respond to                                                                                 
                   ptiwatthanont@gmail.com                                                                              
                                                                                                                        
                                                                                                                        
                                                                                                                        
                                                                                                                        




Dear,If don't take your time too much, please explain me how to use
this patch files.

Thank you very much
iPAS

Marc.Obbad@smsc.com wrote:
      I have downloaded RSTP from this site:


            http://developer.osdl.org/shemminger/prototypes/rstp-2.4.zip


      -Marc






                   Stephen Hemminger

                   <shemminger@linux-foundation.org>

                   Sent by:
      To
                   bridge-bounces@lists.osdl.org               Marc Obbad/SMSC@SMSC

      cc
                                                               netdev@vger.kernel.org, bridge@linux-foundation.org

                   03/09/2007 01:55 PM
      Subject
                                                               Re: [Bridge] rstp for 2.4 kernel: port state keeps
      changing










      On Fri, 9 Mar 2007 12:24:40 -0500
      Marc.Obbad@smsc.com wrote:


            Hi,

            I am using RSTP for 2.4 kernel.


      RSTP is not in the mainline kernel tree. Please post the patch or a where the
      source can be downloaded.

      --
      Stephen Hemminger <shemminger@linux-foundation.org>
      _______________________________________________
      Bridge mailing list
      Bridge@lists.osdl.org
      https://lists.osdl.org/mailman/listinfo/bridge


      _______________________________________________
      Bridge mailing list
      Bridge@lists.osdl.org
      https://lists.osdl.org/mailman/listinfo/bridge

        _______________________________________________
      Bridge mailing list
      Bridge@lists.osdl.org
      https://lists.osdl.org/mailman/listinfo/bridge


