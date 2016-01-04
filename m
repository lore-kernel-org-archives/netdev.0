From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] rsi: Delete unnecessary variable initialisations in
 rsi_send_mgmt_pkt()
Date: Mon, 4 Jan 2016 17:25:13 +0300
Message-ID: <20160104142513.GL5284@mwanda>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5687E169.4070704@users.sourceforge.net>
 <5687E203.1070404@users.sourceforge.net>
 <20160104092857.GD5284@mwanda>
 <87poxhiivf.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87poxhiivf.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 04, 2016 at 02:17:40PM +0100, Bj=F8rn Mork wrote:
> Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> writes:
>=20
> > Please stop sending cleanup patches, Markus.  Just send fixes.
>=20
> Thanks for your continued but unwarranted belief in AI.
>=20

I always tell people that I am very mechanical and you can rely on me t=
o
send predictable responses...

> Do you mind if I remind you of https://lkml.org/lkml/2014/11/3/162 ?
> I am sure there are lots and lots of other examples.  There is no rea=
son
> to believe this will ever stop.  He just goes into Eliza mode.

Yup.

I feel some sense of responsibility for any patches where kernel-janito=
rs
is on the CC but I'm having a hard time dealing with all of Markus's
patches.  Normally you just respond to the first patch and people chang=
e
the later patches but, as you put it, Markus just goes into ELIZA mode.

regards,
dan carpenter

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
