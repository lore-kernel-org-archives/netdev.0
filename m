From: "Kotur, Somnath" <Somnath.Kotur@Emulex.Com>
Subject: RE: [PATCH net-next 0/2] be2net: patch set
Date: Mon, 18 Mar 2013 08:29:27 +0000
Message-ID: <b18303f9-ba56-476c-a7a9-5129160a472f@CMEXHTCAS1.ad.emulex.com>
References: <bfd8205d-1c91-4947-88f7-c27554b4dd06@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: "Kotur, Somnath" <Somnath.Kotur@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:17703 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796Ab3CRI3d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 04:29:33 -0400
In-Reply-To: <bfd8205d-1c91-4947-88f7-c27554b4dd06@CMEXHTCAS2.ad.emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,
 These patches have already been applied. Pls ignore ,they were sent by mistake! 

Thanks
Som

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Somnath Kotur
> Sent: Monday, March 18, 2013 12:34 PM
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net; Kotur, Somnath
> Subject: [PATCH net-next 0/2] be2net: patch set
> 
> Pls apply.
> 
> Somnath Kotur (2):
>   be2net: enable interrupts in be_probe() (RoCE and other ULPs need
>     them)
>   be2net: Use new F/W mailbox cmd to manipulate interrupts.
> 
>  drivers/net/ethernet/emulex/benet/be_cmds.c |   25
> +++++++++++++++++
>  drivers/net/ethernet/emulex/benet/be_cmds.h |    8 +++++
>  drivers/net/ethernet/emulex/benet/be_main.c |   38 ++++++++++++++++-
> ---------
>  3 files changed, 56 insertions(+), 15 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
