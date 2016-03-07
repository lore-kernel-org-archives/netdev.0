From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 0/3] net: macb: Fix coding style issues
Date: Mon, 7 Mar 2016 18:13:46 +0100
Message-ID: <56DDB6CA.8000100@atmel.com>
References: <1457367460-9123-1-git-send-email-moritz.fischer@ettus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Moritz Fischer <moritz.fischer@ettus.com>,
	Michal Simek <michal.simek@xilinx.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	"David Miller" <davem@davemloft.net>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:9577 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbcCGRNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 12:13:38 -0500
In-Reply-To: <1457367460-9123-1-git-send-email-moritz.fischer@ettus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/03/2016 17:17, Moritz Fischer a =E9crit :
> Hi Nicolas,
>=20
> this series deals with most of the checkpatch warnings
> generated for macb. There are two BUG_ON()'s that I didn't touch, yet=
,
> that were suggested by checkpatch, that I can address in a follow up
> commit if needed.
> Let me know if you want me to split the fixes differently or squash
> them into one commit.

Hi,

I'm not usually fond of this type of patches, but I must admit that thi=
s
series corrects some style issues.

So, I would like more feedback from Michal and Cyrille as these changes
may delay some of the not-merged-yet features or more important
work-in-progress on their side.

On the other hand, if we all think it's a calm period for this macb
driver, we may find interesting to merge some "cleanup and style"
enhancements.

Thanks, bye,


> Moritz Fischer (3):
>   net: macb: Fix coding style error message
>   net: macb: Fix more coding style issues
>   net: macb: Address checkpatch 'check' suggestions
>=20
>  drivers/net/ethernet/cadence/macb.c | 157 ++++++++++++++++----------=
----------
>  1 file changed, 71 insertions(+), 86 deletions(-)
>=20


--=20
Nicolas Ferre
