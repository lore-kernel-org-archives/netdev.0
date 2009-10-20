From: "Kumar Gopalpet-B05799" <Sandeep.Kumar@freescale.com>
Subject: RE: [PATCH v0 1/7] gianfar: Add per queue structure support
Date: Tue, 20 Oct 2009 13:57:57 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B8940F9@zin33exm22.fsl.freescale.net>
References: <20091019.231633.25328647.davem@davemloft.net><9F4C7D19E8361D4C94921B95BE08B81B8940DB@zin33exm22.fsl.freescale.net><20091020.000358.53030357.davem@davemloft.net> <20091020.005646.227664762.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:51588 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbZJTI14 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 04:27:56 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n9K8S0KF014537
	for <netdev@vger.kernel.org>; Tue, 20 Oct 2009 01:28:01 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n9K8Ue37008181
	for <netdev@vger.kernel.org>; Tue, 20 Oct 2009 03:30:41 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20091020.005646.227664762.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Will respin them and send again.

-Thanks
Sandeep 

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net] 
>Sent: Tuesday, October 20, 2009 1:27 PM
>To: Kumar Gopalpet-B05799
>Cc: netdev@vger.kernel.org
>Subject: Re: [PATCH v0 1/7] gianfar: Add per queue structure support
>
>From: David Miller <davem@davemloft.net>
>Date: Tue, 20 Oct 2009 00:03:58 -0700 (PDT)
>
>> From: "Kumar Gopalpet-B05799" <Sandeep.Kumar@freescale.com>
>> Date: Tue, 20 Oct 2009 12:15:14 +0530
>> 
>>> I am assuming all the 7 patches are applied.
>> 
>> I am going to add them, yes.
>
>Nevermind, these patches don't apply to net-next-2.6 at all 
>and will need to be respun.
>
>For example, patch #1 rejects because gfar_suspend() in
>net-next-2.6 takes a 'dev' not an 'ofdev'.
>
>
