From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: L2TP support?
Date: Fri, 23 Mar 2007 08:05:35 +0100
Message-ID: <1dd201c76d19$a7df2ea0$061010ac@intranet.dti2.net>
References: <4602AA25.6020001@katalix.com> <200703221833.33530.netdev@axxeo.de> <4602E374.4010802@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=response
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "James Chapman" <jchapman@katalix.com>,
	"Ingo Oeser" <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:3673 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933960AbXCWHLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 03:11:45 -0400
Received: from cintasverdes ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v9.5.6)
	with ESMTP id md50000354131.msg
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2007 08:05:39 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Original Message ----- 
From: "James Chapman" <jchapman@katalix.com>
To: "Ingo Oeser" <netdev@axxeo.de>
Cc: <netdev@vger.kernel.org>
Sent: Thursday, March 22, 2007 9:13 PM
Subject: Re: L2TP support?


> Yes there is. There's a pppd plugin which comes with the openl2tp project, 
> http://sf.net/projects/openl2tp. OpenL2TP supports both LAC and LNS 
> operation. A patch is also available to allow this driver to be used with 
> another L2TP implementation, l2tpd.
>


    Well, I am using a modified rp-l2tp with the pppol2tp kernel module 
myself so now it accounts for three implementations I guess :-)

    -Jorge

==============================================================
Jorge Boncompte - Ingenieria y Gestion de RED
DTI2 - Desarrollo de la Tecnologia de las Comunicaciones
--------------------------------------------------------------
C/ Abogado Enriquez Barrios, 5   14004 CORDOBA (SPAIN)
Tlf: +34 957 761395 / FAX: +34 957 450380
==============================================================
- Sin pistachos no hay Rock & Roll...
- Without wicker a basket cannot be made.
==============================================================


