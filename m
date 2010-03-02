From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH 0/8]: Bug fixes and new FW patch series
Date: Tue, 2 Mar 2010 11:14:09 -0800
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADCB46A2B4A6@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1266408196.25691.841.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1092 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751331Ab0CBTOY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 14:14:24 -0500
In-Reply-To: <1266408196.25691.841.camel@lb-tlvb-vladz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, it seems that u have forgotten to apply the 7-th patch from that series (the one that removes the old bnx2x firmware ver. 5.2.7).

The old .ihex files are still present in the master branch.

Could u, pls., check that u have applied the mentioned patch.

Thanks,
vlad

> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Vladislav Zolotarov
> Sent: Wednesday, February 17, 2010 2:03 PM
> To: davem@davemloft.net
> Cc: netdev@vger.kernel.org
> Subject: [PATCH 0/8]: Bug fixes and new FW patch series
> 
> Dave, hi.
> Pls., apply the following series of patches.
> It includes a few bugs fixes and a few FW.
> 
> The patches may also be found at
> http://linux.broadcom.com/eilong/1.52.1-6
> 
> thanks,
> vlad
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
