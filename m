From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Mon, 7 Mar 2016 13:35:31 +0100
Message-ID: <56DD7593.5060003@suse.de>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>
 <56DD7172.4000707@suse.de> <2714888.1DdqvJZ8cb@diego>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rockchip@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	LAKML <linux-arm-kernel@lists.infradead.org>
To: =?UTF-8?Q?Heiko_St=c3=bcbner?= <heiko@sntech.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34594 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752212AbcCGMfe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2016 07:35:34 -0500
In-Reply-To: <2714888.1DdqvJZ8cb@diego>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Heiko,

Am 07.03.2016 um 13:24 schrieb Heiko St=FCbner:
> Am Montag, 7. M=E4rz 2016, 13:17:54 schrieb Andreas F=E4rber:
>> Am 06.03.2016 um 20:53 schrieb Andreas F=E4rber:
>>> On next-20160304 the GMAC seems to have regressed, it no longer fin=
ds the
>>> PHY:
>>>
>>> libphy: PHY stmmac-0:ffffffff not found
>>> eth0: Could not attach to PHY
>>> stmmac_open: Cannot attach to PHY (error: -19)
>>
>> Still with us in next-20160307. CC'ing stmmac maintainers.
>=20
> do you remember from what revision you rebased away from, when it was=
 still=20
> working (as a known-good state)?

Hm, next-20160111 possibly... leaving all the 5 days and 4 days ago
changes as candidates ("stmmac: share reset function between dwmac100
and dwmac1000" .. "stmmac: Fix 'eth0: No PHY found' regression").

Regards,
Andreas

--=20
SUSE Linux GmbH, Maxfeldstr. 5, 90409 N=FCrnberg, Germany
GF: Felix Imend=F6rffer, Jane Smithard, Graham Norton; HRB 21284 (AG N=FC=
rnberg)
