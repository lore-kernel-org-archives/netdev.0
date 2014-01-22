From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Wed, 22 Jan 2014 12:54:53 +0100
Message-ID: <CAMuHMdWYYh=N-ApUV0tFZW4iHXun_yfuUjqZGVsZ1vjZTDqXMg@mail.gmail.com>
References: <52DD0CC1.70205@pengutronix.de>
	<CAMuHMdV5sMUnXb1Z1HeRk9+_dCGWrbD-DS62S7T4Be-77HvsvA@mail.gmail.com>
	<52DD0F72.1000005@pengutronix.de>
	<20140120.111614.394228612374217980.davem@davemloft.net>
	<52DD9F3C.7000408@cogentembedded.com>
	<52DD927B.2060500@pengutronix.de>
	<52DFB101.8040907@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wg@grandegger.com, linux-can@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Pavel Kiryukhin <vksavl@gmail.com>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:62083 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755238AbaAVLyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 06:54:54 -0500
In-Reply-To: <52DFB101.8040907@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 22, 2014 at 12:52 PM, Ben Dooks <ben.dooks@codethink.co.uk> wrote:
> IIRC, a compiler has the right to pad, or re-order structure
> elements as it sees fit depending on the architecture and options.

Pad: yes, reorder: no.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
