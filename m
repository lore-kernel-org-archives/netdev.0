From: "Hartkopp, Oliver (K-EFFI/P)" <oliver.hartkopp@volkswagen.de>
Subject: AW: [Uclinux-dist-devel] [PATCH] can: bfin_can: switch to common Blackfin can header
Date: Fri, 19 Mar 2010 07:56:29 +0100
Message-ID: <26B4E6A46012A1469B4EB3BC2A7CAAEC44EF47@vwagwox00084.vw.vwg>
References: <8bd0f97a1003162145i77f65158ne255b28239e1b595@mail.gmail.com> <20100316.220232.170244945.davem@davemloft.net> <8bd0f97a1003162225i439d9900mfdc03eca5de0ff6e@mail.gmail.com> <20100316.225150.213941689.davem@davemloft.net> <8bd0f97a1003182335l3c121d87v9369145852c9545d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <socketcan-core@lists.berlios.de>, <netdev@vger.kernel.org>,
	<uclinux-dist-devel@blackfin.uclinux.org>,
	"Thuermann, Urs, Dr. (K-EFFI/I)" <urs.thuermann@volkswagen.de>
To: "Mike Frysinger" <vapier.adi@gmail.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxout1.volkswagen.de ([194.114.62.41]:23592 "EHLO
	mxout1.volkswagen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab0CSHDd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 03:03:33 -0400
Content-class: urn:content-classes:message
In-Reply-To: <8bd0f97a1003182335l3c121d87v9369145852c9545d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mike,

your patch is just a cleanup and definitely not mission-critical.

Please wait until your needed environment emerges in Dave's net-2.6 or
net-next-2.6 tree until you post your patch for the specific tree then.

This makes it much easier - at least for Dave.

Thanks,
Oliver



-----Urspr=FCngliche Nachricht-----
Von: Mike Frysinger [mailto:vapier.adi@gmail.com]=20
Gesendet: Freitag, 19. M=E4rz 2010 07:35
An: David Miller
Cc: socketcan-core@lists.berlios.de; netdev@vger.kernel.org; uclinux-di=
st-devel@blackfin.uclinux.org; Hartkopp, Oliver (K-EFFI/P); Thuermann, =
Urs, Dr. (K-EFFI/I)
Betreff: Re: [Uclinux-dist-devel] [PATCH] can: bfin_can: switch to comm=
on Blackfin can header

On Wed, Mar 17, 2010 at 01:51, David Miller wrote:
> From: Mike Frysinger <vapier.adi@gmail.com>
>> if the next tree is merged into linux-next, then the header is alrea=
dy there
>
> One of the highest priority trees in -next is net-next-2.6,
> because so much other stuff ends up depending upon it.
>
> Therefore I keep it building independently, so no matter what Stephen
> Rothwell does the build isn't likely to break.
>
> Just get your stuff merged properly to Linus then resubmit
> your patch.

Linus has pulled my tree, so there shouldnt be any reason to not merge
this patch now
-mike
