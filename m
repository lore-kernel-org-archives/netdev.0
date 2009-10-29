From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [PATCH v2 4/7] fsl_pq_mdio: Add Suport for etsec2.0 devices.
Date: Thu, 29 Oct 2009 16:03:30 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B950364@zin33exm22.fsl.freescale.net>
References: <9F4C7D19E8361D4C94921B95BE08B81B950352@zin33exm22.fsl.freescale.net><20091029.024546.90958594.davem@davemloft.net><9F4C7D19E8361D4C94921B95BE08B81B95035E@zin33exm22.fsl.freescale.net> <20091029.031610.04742718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <avorontsov@ru.mvista.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:57958 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550AbZJ2Kd3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 06:33:29 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n9TAXX9O021215
	for <netdev@vger.kernel.org>; Thu, 29 Oct 2009 03:33:33 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n9TAaSw8020071
	for <netdev@vger.kernel.org>; Thu, 29 Oct 2009 05:36:29 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20091029.031610.04742718.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net] 
>Sent: Thursday, October 29, 2009 3:46 PM
>To: Kumar Gopalpet-B05799
>Cc: netdev@vger.kernel.org; avorontsov@ru.mvista.com
>Subject: Re: [PATCH v2 4/7] fsl_pq_mdio: Add Support for 
>etsec2.0 devices.
>
>From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
>Date: Thu, 29 Oct 2009 15:41:22 +0530
>
>> This is the tree I generated the patches against initially. 
>> The initial set of patches were generated against this tree:
>> 
>(http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
>> )
>> 
>> Can you please confirm that the above tree is correct.
>
>Yes.

Thank you. I cloned this tree again about 2 hours ago (and updated it 5
mins ago as well).
git describe:
v2.6.32-rc3-464-gb37b62f

The last commit is: b37b62fea1d1bf68ca51818f8eb1035188efd030


>
>> The patches sent by me applies cleanly to the above mentioned
>> net-next-2.6 tree. 
>
>It may have applied cleanly when you sent them, but by the 
>time I applied them it didn't.

The PATCH v2 series applied cleanly to the above clone.

>
>Resend a fresh patch set against a fresh net-next-2.6 checkout 
>and let's see what happens :-)
Ok. But there is NO change to the patch set.


--

Thanks
Sandeep
