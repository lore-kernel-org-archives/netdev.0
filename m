From: Greg KH <greg@kroah.com>
Subject: Re: [RESEND] benet: BladeEngine 10Gb NIC driver
Date: Tue, 4 Nov 2008 21:02:09 -0800
Message-ID: <20081105050209.GC3730@kroah.com>
References: <20081103122512.06063fc9@mailhost.serverengines.com> <20081103193641.GA12552@kroah.com> <490F5667.3080904@garzik.org> <20081103201930.GB13299@kroah.com> <Pine.LNX.4.64.0811041237400.23792@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>,
	Subbu Seetharaman <subbus@serverengines.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:42013 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750743AbYKEFPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 00:15:00 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0811041237400.23792@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 04, 2008 at 12:41:36PM +0200, Ilpo J=E4rvinen wrote:
> On Mon, 3 Nov 2008, Greg KH wrote:
>=20
> > Hm, call me extreemly stupid, but I don't see anything in that bran=
ch
> > for this driver.
> >=20
> > Here's what I did:
> >   git fetch git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/n=
etdev-2.6.git benet master:jeff
>=20
> I suppose you'd have needed instead of "benet master:jeff" just:
>=20
> benet:jeff
>=20
> Ie., from benet remote branch to jeff local branch (remote from the g=
iven
> repository obviously). ...Then you have that jeff branch and can chec=
kout=20
> it.

Ah, thanks, I'll try that next time.

greg k-h
