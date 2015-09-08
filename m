From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] usbnet: Fix a race between usbnet_stop() and the BH
Date: Tue, 08 Sep 2015 09:48:53 +0200
Message-ID: <1441698533.26994.23.camel@suse.com>
References: <1441094336.3328.1.camel@suse.com>
	 <1441116333-5377-1-git-send-email-eugene.shatokhin@rosalab.ru>
	 <55EE8D19.8020703@rosalab.ru> <87fv2ppdjv.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87fv2ppdjv.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-09-08 at 09:37 +0200, Bj=C3=B8rn Mork wrote:
> Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:
>=20
> > I resent the patch to make it separate. What is the status of this =
now?
>=20
> One of the many nice features of patchwork is that you don't need to =
ask
> those questions :)
>=20
> See http://patchwork.ozlabs.org/patch/512856/
>=20
> I really don't think it's appropriate for me to ack this, but I can a=
dd
> my

Well, in case this helps:

> Reviewed-by: Bj=C3=B8rn Mork <bjorn@mork.no>
Acked-by: Oliver Neukum <oneukum@suse.com>

	Regards
		Oliver
