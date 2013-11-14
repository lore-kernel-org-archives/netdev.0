From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/7990: Make lance_private.name const
Date: Thu, 14 Nov 2013 04:11:53 -0500 (EST)
Message-ID: <20131114.041153.710180834471836406.davem@davemloft.net>
References: <CAMuHMdXyqOATvE8e=3Ed17bwiDRE8w=B=xKuYwd5qorxqA0BJg@mail.gmail.com>
	<20131113.151301.100218641838867631.davem@davemloft.net>
	<CAMuHMdWN5KGYYZuMYF+cH8dtT9cuaWQNJaaE4wC0LXRVBBrmyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdWN5KGYYZuMYF+cH8dtT9cuaWQNJaaE4wC0LXRVBBrmyw@mail.gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 14 Nov 2013 09:37:32 +0100

> Sorry, I didn't get that message. I was puzzled by your request to correct
> the whitespace of the lines I touched only, which causes them to stand out
> in a block of old non-compliant whitespace.

It's very hard to stand out in this source file, even in the first
hunk of your patch the very next line already used proper TABs.
