From: Cong Wang <cwang@twopensource.com>
Subject: Re: [request for stable inclusion] ipv6: reallocate addrconf router
 for ipv6 address when lo device up
Date: Mon, 16 Jun 2014 10:19:08 -0700
Message-ID: <CAHA+R7NL+J19a4WPcWTWo928Sr7ORxnE6sTh12C+bN8K7yNyHQ@mail.gmail.com>
References: <1402884279-11896-1-git-send-email-chenweilong@huawei.com>
	<20140615.192955.2126802764510967888.davem@davemloft.net>
	<539E611F.6000805@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, gregkh@linuxfoundation.org,
	gaofeng@cn.fujitsu.com, stable@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>, lizefan@huawei.com
To: chenweilong <chenweilong@huawei.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <539E611F.6000805@huawei.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 15, 2014 at 8:14 PM, chenweilong <chenweilong@huawei.com> wrote:
> Oh..sorry,
>
> I must missed something important!

Yes, you miss the FAQ:
https://www.kernel.org/doc/Documentation/networking/netdev-FAQ.txt

> What's the right way?
>

Q: How can I tell what patches are queued up for backporting to the
   various stable releases?

A: Normally Greg Kroah-Hartman collects stable commits himself, but
   for networking, Dave collects up patches he deems critical for the
   networking subsystem, and then hands them off to Greg.
