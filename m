From: Alexey Orishko <alexey.orishko@gmail.com>
Subject: Re: [PATCH net 0/3] cdc_ncm and cdc_mbim fixes for 3.8
Date: Mon, 21 Jan 2013 21:34:11 +0100
Message-ID: <CAL_Kpj2QsUqLLCnME3zNHxJpcrJZufN1ZMT=vRsr_gzs70gvpQ@mail.gmail.com>
References: <1358783440-11459-1-git-send-email-bjorn@mork.no>
	<20130121.142242.2240250911008731906.davem@davemloft.net>
	<2AC7D4AD8BA1C640B4C60C61C8E520154A8EE17D99@EXDCVYMBSTM006.EQ1STM.local>
	<f47edcc4-cda9-4349-9590-ee8572b139ca@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey ORISHKO <alexey.orishko@stericsson.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"gsuarez@smithmicro.com" <gsuarez@smithmicro.com>,
	"oneukum@suse.de" <oneukum@suse.de>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:42680 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898Ab3AUUeM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 15:34:12 -0500
In-Reply-To: <f47edcc4-cda9-4349-9590-ee8572b139ca@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2013 at 9:16 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Alexey ORISHKO <alexey.orishko@stericsson.com> wrote:
>
>
> There are still a couple of questions I am wondering about though. Th=
e most important one: what is Windows 8 doing different from us? Does a=
nyone know? I do not have a Windows 8 system myself and I wouldn't know=
 how to snoop on it either.
>

Are you talking about bulk data? They have their own bugs :-) looks
like can't handle divisor/remainder in NTB right.
If you want, I can send you Ellisys log.

Regards,
Alexey
