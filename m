From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Mon, 31 Jan 2011 14:14:58 +0100
Message-ID: <1296479698.8750.55.camel@ceranb.intra.cera.cz>
References: <AANLkTimqkJ3DGBX5iREEcx6sgAM+2CZHNWMU+noNSitp@mail.gmail.com>
	 <20110116192017.GA3569@electric-eye.fr.zoreil.com>
	 <AANLkTi=uNKMj_gs_bKRQ1tQa0TMwdnyrtVcR5JPNpmJv@mail.gmail.com>
	 <AANLkTikoXfgHrJyMbe6A_HmvXT_QRo55w76st5Wo0hSv@mail.gmail.com>
	 <20110118012146.GA3704@electric-eye.fr.zoreil.com>
	 <AANLkTimA1C=trH+WGpBdPU=vBf-cN+xB4Br3+vJb-Qum@mail.gmail.com>
	 <20110127150744.GA7925@electric-eye.fr.zoreil.com>
	 <AANLkTi=OwsMO8x9AOy=MmohU4SSQcv+o=TvwNs0NNsQR@mail.gmail.com>
	 <20110127165031.GA7966@electric-eye.fr.zoreil.com>
	 <AANLkTin17BgJDdTbSMork8XEw4PVz_KrVBZvHdQwTRNH@mail.gmail.com>
	 <20110128120624.GA8100@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Anand Raj Manickam <anandrm@gmail.com>, netdev@vger.kernel.org,
	Hayes <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2880 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755300Ab1AaNPO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 08:15:14 -0500
In-Reply-To: <20110128120624.GA8100@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-01-28 at 13:06 +0100, Francois Romieu wrote:
> Added Ivan to the Cc:. He has got a 8168c with XID 1c4000c0 and may
> tell if
> hardware VLAN works for him or not.
> 
Unfortunately I have no local access (it's placed in China) or remote
serial console to the system with this 8168c. The second problem is that
the system is connected to the switch that does not pass the packets
with VLAN tags -> it seems that at least Tx packets have the VLAN tag.

I'm sorry I'm not able to help more.

Ivan

