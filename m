From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 00/09]IPtablestng/Kernel - New Framework For IPtables
Date: Tue, 28 Oct 2008 15:25:54 +0300
Message-ID: <20081028122554.GA12945@ioremap.net>
References: <20081027042834.0BA69C64087@host1.ystp.ac.ir> <20081028000044.GA16721@ioremap.net> <464293e60810280302j26112754o72c1cf3ebd6a0b1f@mail.gmail.com> <20081028104346.GA31146@ioremap.net> <4907008A.6050808@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hamid jafarian <hamid.jafarian@gmail.com>,
	Netfilter-devel <netfilter-devel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jan Engelhardt <jengelh@medozas.de>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Harald Welte <laforge@gnumonks.org>,
	Eric Leblond <eric@inl.fr>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Amin Azez <azez@ufomechanic.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4907008A.6050808@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 28, 2008 at 01:07:38PM +0100, Patrick McHardy (kaber@trash.net) wrote:
> I think these patches are a lost cause. Besides the fact that they
> move things to the kernel instead of to userspace, they

What about part which replaces rules array with a list?
That's the main part I was interested in though.

-- 
	Evgeniy Polyakov
