From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Tue, 1 Feb 2011 11:12:53 +0100
Message-ID: <20110201101253.GA8681@electric-eye.fr.zoreil.com>
References: <AANLkTi=uNKMj_gs_bKRQ1tQa0TMwdnyrtVcR5JPNpmJv@mail.gmail.com> <AANLkTikoXfgHrJyMbe6A_HmvXT_QRo55w76st5Wo0hSv@mail.gmail.com> <20110118012146.GA3704@electric-eye.fr.zoreil.com> <AANLkTimA1C=trH+WGpBdPU=vBf-cN+xB4Br3+vJb-Qum@mail.gmail.com> <20110127150744.GA7925@electric-eye.fr.zoreil.com> <AANLkTi=OwsMO8x9AOy=MmohU4SSQcv+o=TvwNs0NNsQR@mail.gmail.com> <20110127165031.GA7966@electric-eye.fr.zoreil.com> <AANLkTin17BgJDdTbSMork8XEw4PVz_KrVBZvHdQwTRNH@mail.gmail.com> <20110128120624.GA8100@electric-eye.fr.zoreil.com> <1296479698.8750.55.camel@ceranb.intra.cera.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anand Raj Manickam <anandrm@gmail.com>, netdev@vger.kernel.org,
	Hayes <hayeswang@realtek.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36806 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328Ab1BAKPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 05:15:15 -0500
Content-Disposition: inline
In-Reply-To: <1296479698.8750.55.camel@ceranb.intra.cera.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Vecera <ivecera@redhat.com> :
[...]
> Unfortunately I have no local access (it's placed in China) or remote
> serial console to the system with this 8168c. The second problem is that
> the system is connected to the switch that does not pass the packets
> with VLAN tags -> it seems that at least Tx packets have the VLAN tag.
> 
> I'm sorry I'm not able to help more.

Thanks a lot for the information, it is both welcome and helpful.

I'll freeze Anand's report for now as "8168c + unspecified glue hardware
bug with unknown product manufactured by Arkino on unidentified motherboard
with unknown number of processors".

-- 
Ueimor
