From: Alexey Orishko <alexey.orishko@gmail.com>
Subject: Re: [PATCH net] net: cdc_ncm: workaround for missing CDC Union
Date: Sun, 20 Jan 2013 01:21:20 +0100
Message-ID: <CAL_Kpj1B=_+eN3Y0n3d9_r4JoeHD2LQFSU+b+taCZL0G4icu6A@mail.gmail.com>
References: <1358519147-10073-1-git-send-email-bjorn@mork.no>
	<22276933.xSGyXJfOvq@linux-5eaq.site>
	<871udiur74.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Greg Suarez <gsuarez@smithmicro.com>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:47801 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752242Ab3ATAVV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 19:21:21 -0500
In-Reply-To: <871udiur74.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 18, 2013 at 10:17 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:

>>> Some Sierra Wireless firmwares support CDC MBIM but have no CDC
>>> Union funtional descriptor. This violates the MBIM specification,

I don't believe Sierra Wireless violates MBIM specification.
See in the specification: "there are two ways to group interfaces: the
WHCM Union functional descriptor and IAD."

Regards,
Alexey
