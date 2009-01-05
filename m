From: "Jaswinder Singh Rajput" <jaswinderlinux@gmail.com>
Subject: Re: [PATCH -net-next 3/4] firmware: convert tg3 driver to request_firmware()
Date: Mon, 5 Jan 2009 19:42:37 +0530
Message-ID: <3f9a31f40901050612v700d2542r1e3e400bf0fe3d33@mail.gmail.com>
References: <1230626497.24796.26.camel@jaswinder.satnam>
	 <49620AFE.6040409@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jaswinder Singh Rajput" <jaswinder@infradead.org>,
	davem@redhat.com, jgarzik@redhat.com,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org,
	mchan@broadcom.com, "Alan Cox" <alan@lxorguk.ukuu.org.uk>
To: "Oliver Hartkopp" <oliver@hartkopp.net>,
	"David Woodhouse" <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:55131 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754111AbZAEOMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 09:12:39 -0500
In-Reply-To: <49620AFE.6040409@hartkopp.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 5, 2009 at 6:58 PM, Oliver Hartkopp <oliver@hartkopp.net> wrote:
> 077f849de42e58172e25ccb24df4c1a13e82420c ("firmware: convert tg3 driver to
> request_firmware()")
>
> and i discovered that
>
> 1. I needed to compile the tg3 driver as *module* now as it was not able to
> read the firmware when built-in.
>

Please compile it as build in.

David Woodhouse: Do you have any plans to support firmware by using modules.

Thanks,
JSR.
