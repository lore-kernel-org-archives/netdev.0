From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Seventh release of i82586 drivers: Novell NE3200, Microdyne EXOS
 205T/215T and Intel EtherExpress 16
Date: Sat, 24 Jan 2004 20:09:48 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <4013175C.6090607@pobox.com>
References: <20031031155341.B1773@sygehus.dk> <3FA2854C.9080801@pobox.com> <20031031180525.A1984@sygehus.dk> <20031107192543.A1921@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031107192543.A1921@sygehus.dk>
List-Id: netdev.vger.kernel.org

Rask Ingemann Lambertsen wrote:
> I now have patches against linux 2.4.22-bk45. Due to the size I won't post
> them to the list. They can be downloaded instead:
> 
> <URL:http://users.cybercity.dk/~ccc94453/linux/i82586/i82586-2.4.22bk45.patch1.bz2>
> (bzip2 compressed, 41140 bytes)
> <URL:http://users.cybercity.dk/~ccc94453/linux/i82586/i82586-2.4.22bk45.patch1.txt>
> (uncompressed, 175346 bytes)

I've been slow getting to these... any chance you could re-diff against 
2.4.25-pre7?


> Btw, if/when I make more updates, should I make full patches or
> incremental patches?

Up to you.  In general, I prefer being "mailbombed" with multiple 
patches, against the latest kernel or latest netdev.

	Jeff


P.S. I haven't forgotten about your de2104x mtu patch either, need to 
review that soon.

