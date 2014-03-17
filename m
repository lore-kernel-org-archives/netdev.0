From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276 problem
Date: Mon, 17 Mar 2014 16:07:42 +0100
Message-ID: <87lhw8lv7l.fsf@nemi.mork.no>
References: <87ob19nndo.fsf@nemi.mork.no> <20140314125934.GC3200@reaktio.net>
	<87vbvgnbv3.fsf@nemi.mork.no> <20140314142559.GD3200@reaktio.net>
	<87k3btm57a.fsf@nemi.mork.no> <20140317115919.GK3200@reaktio.net>
	<20140317124555.GL3200@reaktio.net> <87y509kluc.fsf@nemi.mork.no>
	<20140317131731.GM3200@reaktio.net> <87txawlx9h.fsf@nemi.mork.no>
	<20140317150527.GO3200@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas =?utf-8?Q?Sch=C3=A4fer?= <tschaefer@t-online.de>,
	Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>
To: Pasi =?utf-8?B?S8Okcmtrw6RpbmVu?= <pasik@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:36318 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933310AbaCQP3M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 11:29:12 -0400
In-Reply-To: <20140317150527.GO3200@reaktio.net> ("Pasi =?utf-8?Q?K=C3=A4r?=
 =?utf-8?Q?kk=C3=A4inen=22's?= message
	of "Mon, 17 Mar 2014 17:05:27 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pasi K=C3=A4rkk=C3=A4inen <pasik@iki.fi> writes:

> I applied the patch on top of Linux 3.13.6 kernel and now I'm able to=
 use the wwan0 NCM interface successfully!=20
> I do get an IP with a dhcp client (this failed earlier without the pa=
tch), and Internet seems to work OK.=20
> So the patch definitely fixes the problem for me with Huawei E3276 4G=
/LTE USB dongle.=20
>
> Thanks a lot!
>
> Tested-by: Pasi K=C3=A4rkk=C3=A4inen <pasik@iki.fi>

Great!  Thanks a lot for quick testing too.  I'll submit this now.
Might be a bit late for 3.14, but should go to stable the next time
davem submits a batch there.


Bj=C3=B8rn
