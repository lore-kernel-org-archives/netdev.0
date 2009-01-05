From: "Jaswinder Singh Rajput" <jaswinderlinux@gmail.com>
Subject: Re: [PATCH -net-next 3/4] firmware: convert tg3 driver to request_firmware()
Date: Mon, 5 Jan 2009 20:36:47 +0530
Message-ID: <3f9a31f40901050706r3d01fbfen351c1728b5a9095b@mail.gmail.com>
References: <1230626497.24796.26.camel@jaswinder.satnam>
	 <49620AFE.6040409@hartkopp.net>
	 <3f9a31f40901050612v700d2542r1e3e400bf0fe3d33@mail.gmail.com>
	 <49622011.4080203@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Woodhouse" <dwmw2@infradead.org>,
	"Jaswinder Singh Rajput" <jaswinder@infradead.org>,
	davem@redhat.com, jgarzik@redhat.com,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org,
	mchan@broadcom.com, "Alan Cox" <alan@lxorguk.ukuu.org.uk>
To: "Oliver Hartkopp" <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:40388 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087AbZAEPGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 10:06:49 -0500
In-Reply-To: <49622011.4080203@hartkopp.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 5, 2009 at 8:28 PM, Oliver Hartkopp <oliver@hartkopp.net> wrote:
>
> The firmware, right?!
>
> When compiling tg3 as module the request_firmware() worked fine, as the fs
> is available then.
>
> Now i went back to compiling tg3 as built-in driver and i also defined
> CONFIG_FIRMWARE_IN_KERNEL which is also working properly. Thanks for the
> advise.
>

Yes, Good.

> Btw. the locking issue is still there:

David Miller and Jeff are right person to answer this question.

Thanks,
--
JSR
