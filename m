From: Alexey ORISHKO <alexey.orishko@stericsson.com>
Subject: RE: [PATCH net 0/3] cdc_ncm and cdc_mbim fixes for 3.8
Date: Mon, 21 Jan 2013 20:42:11 +0100
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520154A8EE17D99@EXDCVYMBSTM006.EQ1STM.local>
References: <1358783440-11459-1-git-send-email-bjorn@mork.no>
 <20130121.142242.2240250911008731906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"gsuarez@smithmicro.com" <gsuarez@smithmicro.com>,
	"oneukum@suse.de" <oneukum@suse.de>,
	Alexey Orishko <alexey.orishko@gmail.com>
To: David Miller <davem@davemloft.net>, "bjorn@mork.no" <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:33698 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751134Ab3AUTnL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 14:43:11 -0500
In-Reply-To: <20130121.142242.2240250911008731906.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, January 21, 2013 8:23 PM
> To: bjorn@mork.no
> Cc: netdev@vger.kernel.org; linux-usb@vger.kernel.org;
> gsuarez@smithmicro.com; Alexey ORISHKO; oneukum@suse.de
> Subject: Re: [PATCH net 0/3] cdc_ncm and cdc_mbim fixes for 3.8
>=20
> From: Bj=F8rn Mork <bjorn@mork.no>
> Date: Mon, 21 Jan 2013 16:50:37 +0100
>=20
> > The 2 first patches in this series are required to make the Sierra
> > Wireless MC7710 card work in MBIM mode.  They may also be required
> for
> > other Qualcomm firmware based MBIM devices.
> >
> > Patch #1 was previously posted as a standalone patch.  This version
> is
> > a replacement, removing a theoretical NULL pointer exception.
> >
> > Patch #3 fixes a bug I introduced in v3.7
>=20
> All applied, thanks.

Hi David,

It was way too fast... I don't think we concluded on patch#2 since it
will damage existing devices :-(

Regards,
alexey
