From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 4/5] Net: ath5k, license is GPLv2
Date: Wed, 29 Aug 2007 21:37:48 +0200
Message-ID: <200708292137.48834.mb@bu3sch.de>
References: <2713029743177393055@pripojeni.net> <20070829192858.75aa6542@the-village.bc.nu> <9e4733910708291233h3c4022a9n6e46733c5c50e222@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Alan Cox" <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	"Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org" <Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org>,
	"Christoph Hellwig" <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"Jiri Slaby" <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Jon Smirl" <jonsmirl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9e4733910708291233h3c4022a9n6e46733c5c50e222-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 29 August 2007 21:33:43 Jon Smirl wrote:
> What if a patch spans both code that is pure GPL and code imported
> from BSD, how do you license it?

I think it's a valid assumption, if we say that the author
of the patch read the license header of a file and agreed with it.
So the patch is licensed to whatever the fileheader says. And if
there's none, it's licensed with the COPYING terms.
If a patch author likes some other license conditions, he must
explicitely add them with the patch to the file, saying that this
and that part have these and those conditions. Of course they must
be compatible with the original license.

-- 
Greetings Michael.
