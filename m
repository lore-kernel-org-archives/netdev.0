From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH V2 1/2] brcm80211: use container_of to resolve brcms_phy
 from brcms_phy_pub
Date: Sat, 27 Sep 2014 10:22:24 +0200 (CEST)
Message-ID: <2023667085.710256.1411806144444.open-xchange@webmail.nmp.skynet.be>
References: <1410809448-15982-1-git-send-email-fabf@skynet.be> <20140926174636.GJ22967@tuxdriver.com>
Reply-To: Fabian Frederick <fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org,
	Arend van Spriel <arend@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	brcm80211-dev-list@broadcom.com, brudley@broadcom.com
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140926174636.GJ22967@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 26 September 2014 at 19:46 "John W. Linville" <linville@tuxdriver.=
com>
> wrote:
>
>
> These two patches don't seem to apply on wireless-next, and I don't
> have time at the moment to fix them up.=C2=A0 Feel free to repost...

Hello John,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 No problem, you already pushed the 2 same p=
atches from the first (too
generic) patchset

=C2=A0 =C2=A0 =C2=A0 =C2=A0 First patchset for drivers/net (see patch 3=
 and 4)
=C2=A0 =C2=A0 =C2=A0 =C2=A0 http://marc.info/?l=3Dlinux-kernel&m=3D1410=
64073901334&w=3D2
=C2=A0 =C2=A0 =C2=A0 =C2=A0
=C2=A0 =C2=A0 =C2=A0 =C2=A0 No updates in V2 anyway:
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ("V2: 2 separate patches for brcm80211")

Wireless-next commits:
a38a9ef1c064
("brcm80211: use container_of to resolve dma_info from dma_pub")

d68e9f5d8549
("brcm80211: use container_of to resolve brcms_phy from brcms_phy_pub")

Regards,
=46abian
