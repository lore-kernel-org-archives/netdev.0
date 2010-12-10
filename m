From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Adding Support for SG,GSO,GRO
Date: Fri, 10 Dec 2010 16:20:28 +0000
Message-ID: <1291998028.11673.6.camel@bwh-desktop>
References: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
	 <1291906948.19763.16.camel@localhost>
	 <AANLkTi=8zWMYWG0DU147B08nN7xcvwaB9Bpq9fE8_fBe@mail.gmail.com>
	 <20101209.113806.71114756.davem@davemloft.net>
	 <AANLkTi=7NLkHW6c88gUcyW8i0Wwmf2Cw4NdmRiGci4kE@mail.gmail.com>
	 <20101210143140.GD3536057@jupiter.n2.diac24.net>
	 <AANLkTi=cVufUAHn6LRs_vG-cW2cY87SdP9MOE7i5Ru09@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Lamparter <equinox@diac24.net>,
	David Miller <davem@davemloft.net>, srk@ti.com,
	netdev@vger.kernel.org, Jens Axboe <axboe@kernel.dk>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20973 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756170Ab0LJQUc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 11:20:32 -0500
In-Reply-To: <AANLkTi=cVufUAHn6LRs_vG-cW2cY87SdP9MOE7i5Ru09@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-12-10 at 17:01 +0100, Micha=C5=82 Miros=C5=82aw wrote:
[...]
> The question is do we really want good checksum for bogus data?
[...]

It's not bogus data.  It's a snapshot of the file contents at some
arbitrary point in time.

Now please stop wasting your own time and that of the networking
maintainers, and remember to check for checksum offload next time you
need to select a network controller.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

