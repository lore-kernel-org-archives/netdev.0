From: Kumar S <ps2kumar@yahoo.com>
Subject: phylib autonegotiation issue with the Freescale Quicc engine and BCM 5481 Phy
Date: Mon, 4 Apr 2011 10:53:42 -0700 (PDT)
Message-ID: <773273.75785.qm@web113916.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm27.bullet.mail.sp2.yahoo.com ([98.139.91.97]:39353 "HELO
	nm27.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754973Ab1DDRxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 13:53:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
We are using Freescale MPC8360E with Quicc Engine and BCM 5481 Phy. BCM 5481 supports autonegotiation and the Quicc Engine drivers allows us to configure the MAC and phy with auto negotiation and force speed. But when the auto negotian is off, looks like the phylib is autonegotiating and trying different rates similar to:
 
http://kerneltrap.org/mailarchive/linux-netdev/2008/7/3/2340034
 
I'm not sure whether I should be using the phylib. Also I'm not sure whether I can disable it. I'm new to linux drivers. Could somebody give me some pointers on this issue?
 
Thanks & regards
Kumar




      
