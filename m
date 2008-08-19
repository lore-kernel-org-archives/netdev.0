From: Karsten Keil <kkeil@suse.de>
Subject: Re: [PATCH] misdn: fix multistatement if block missing braces
Date: Tue, 19 Aug 2008 11:22:13 +0200
Message-ID: <20080819092213.GA15637@pingi.kke.suse.de>
References: <Pine.LNX.4.64.0808190946270.4551@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kkeil@suse.de, Jeff Garzik <jeff@garzik.org>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:51067 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754046AbYHSJWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 05:22:16 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0808190946270.4551@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, applied to=20
git://git.kernel.org/pub/scm/linux/kernel/git/kkeil/ISDN-2.6.git

On Tue, Aug 19, 2008 at 09:51:39AM +0300, Ilpo J=E4rvinen wrote:
>=20
> ...Once again these show up though not causing any harm in
> this case (yet).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  drivers/isdn/mISDN/dsp_cmx.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/isdn/mISDN/dsp_cmx.c b/drivers/isdn/mISDN/dsp_cm=
x.c
=2E..

--=20
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex,=
 HRB 16746 (AG Nuernberg)
