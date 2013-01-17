From: David Miller <davem@davemloft.net>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and
 <linux/in6.h>
Date: Wed, 16 Jan 2013 21:05:12 -0500 (EST)
Message-ID: <20130116.210512.2230612692562212911.davem@davemloft.net>
References: <1358351232.2923.10.camel@bwh-desktop.uk.solarflarecom.com>
	<20130116.164511.2027039182184636075.davem@davemloft.net>
	<50F75AD7.7000703@systemhalted.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, yoshfuji@linux-ipv6.org, amwang@redhat.com,
 tmb@mageia.org, eblake@redhat.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, libvirt-list@redhat.com, tgraf@suug.ch,
 libc-alpha@sourceware.org, schwab@suse.de
To: carlos@systemhalted.org
Return-path: <libc-alpha-return-36346-glibc-alpha=m.gmane.org@sourceware.org>
In-Reply-To: <50F75AD7.7000703@systemhalted.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

From: Carlos O'Donell <carlos@systemhalted.org>
Date: Wed, 16 Jan 2013 20:58:47 -0500

> So I just went down the rabbit hole, and the further I get the
> closer I get to having two exact copies of the same definitions
> in both glibc and the kernel and using whichever one was included
> first.
> 
> Is anyone opposed to that kind of solution?

Sounds interesting, please share :-)
