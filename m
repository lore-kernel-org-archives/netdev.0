From: <Somnath.Kotur@Emulex.Com>
Subject: RE: [PATCH net-next 0/4] be2net fixes
Date: Wed, 2 May 2012 07:04:52 -0700
Message-ID: <ca4655b2-2790-4504-bf56-532ef1895c2f@exht1.ad.emulex.com>
References: <1335965986-31886-1-git-send-email-somnath.kotur@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <Somnath.Kotur@Emulex.Com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:19562 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753039Ab2EBOFS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 10:05:18 -0400
In-Reply-To: <1335965986-31886-1-git-send-email-somnath.kotur@emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,
Have sent the 4 patches from the earlier patch series of 5 as is without updating the individual patch numbers i.e they still denote patch 1/5 etc.
Pls let me know if this is a problem and/or if you want me to resend them again? 

Thanks
Somnath

> -----Original Message-----
> From: Somnath Kotur [mailto:somnath.kotur@emulex.com]
> Sent: Wednesday, May 02, 2012 7:10 PM
> To: netdev@vger.kernel.org
> Cc: Kotur, Somnath
> Subject: [PATCH net-next 0/4] be2net fixes
> 
> Re-posting patches 1-4 from the earlier patch set of 5.
> Incorporated review comment from Ben Hutchings in patch 2.
> Will address comments in Patch 5 and send it out seperately.
> 
> Somnath Kotur (4):
>   be2net: Fix to not set link speed for disabled functions of a UMC
>     card
>   be2net: Fix to apply duplex value as unknown when link is down.
>   be2net: Record receive queue index in skb to aid RPS.
>   be2net: Fix EEH error reset before a flash dump completes
> 
>  drivers/net/ethernet/emulex/benet/be_ethtool.c |    4 ++--
>  drivers/net/ethernet/emulex/benet/be_main.c    |    7 +++++++
>  2 files changed, 9 insertions(+), 2 deletions(-)
