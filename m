From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/09]IPtablestng/Kernel - New Framework For IPtables
Date: Mon, 27 Oct 2008 17:02:11 -0700 (PDT)
Message-ID: <20081027.170211.119803913.davem@davemloft.net>
References: <20081027042834.0BA69C64087@host1.ystp.ac.ir>
	<20081028000044.GA16721@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hamid.jafarian@gmail.com, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	jengelh@medozas.de, rusty@rustcorp.com.au, laforge@gnumonks.org,
	eric@inl.fr, kadlec@blackhole.kfki.hu, azez@ufomechanic.net
To: zbr@ioremap.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081028000044.GA16721@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Tue, 28 Oct 2008 03:00:44 +0300

> On Mon, Oct 27, 2008 at 07:58:33AM +0330, hamid jafarian (hamid.jafarian@gmail.com) wrote:
> > New Framework for IPtables
> 
> Frankly saying your codying style is way out of expected range of
> allowed glitches, so it is quite hard to review the whole thing. Please
> update it to at least remotely match existing code. Also I noticed you
> do not use list iteration functions sometimes and replaces them with
> direct access to next/prev pointers, which is not a good idea.

And also please remove me from the CC: list as I have zero interest
in these patches.

Thanks.

