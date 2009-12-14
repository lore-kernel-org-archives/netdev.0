From: andrew hendry <andrew.hendry@gmail.com>
Subject: Re: [GIT]: Networking
Date: Tue, 15 Dec 2009 09:07:23 +1100
Message-ID: <d45a3acc0912141407s23cdbc1cw8d5dfdbc0e1b556a@mail.gmail.com>
References: <20091205.193505.193701079.davem@davemloft.net>
	 <20091213.202037.229738549.davem@davemloft.net>
	 <d45a3acc0912132026w5ab6b3b3x3f211566779257d3@mail.gmail.com>
	 <200912141253.42017.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Henner Eisen <eis@baty.hanse.de>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:45810 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758593AbZLNWHZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 17:07:25 -0500
In-Reply-To: <200912141253.42017.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That works for me. I have access to some X.25 networks for testing and
keep an eye on the mailing lists.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

On Mon, Dec 14, 2009 at 10:53 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Monday 14 December 2009, andrew hendry wrote:
>> Thanks, I didn't know X.25 was actively maintained. I get bounces.
>> Is the the maintainers out of date?
>
> From looking at the posts on the x.25 mailing list and the changes
> that went into the kernel during the last three years in that area,
> I think it is safe to say that you are now the maintainer ;-).
>
> The last mail on this topic from Henner Eisen was around 2001.
>
>> AX.25 NETWORK LAYER
>> M: =A0 =A0 =A0Ralf Baechle <ralf@linux-mips.org>
>>
>> X.25 NETWORK LAYER
>> M: =A0 =A0 =A0Henner Eisen <eis@baty.hanse.de>
>
> How about this change?
>
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -5839,9 +5839,9 @@ F: =A0 =A0 =A0 =A0sound/soc/codecs/wm8350.c
> =A0F: =A0 =A0 sound/soc/codecs/wm8400.c
>
> =A0X.25 NETWORK LAYER
> -M: =A0 =A0 Henner Eisen <eis@baty.hanse.de>
> +M: =A0 =A0 Andrew Hendry <andrew.hendry@gmail.com>
> =A0L: =A0 =A0 linux-x25@vger.kernel.org
> -S: =A0 =A0 Maintained
> +S: =A0 =A0 Odd Fixes
> =A0F: =A0 =A0 Documentation/networking/x25*
> =A0F: =A0 =A0 include/net/x25*
> =A0F: =A0 =A0 net/x25/
>
