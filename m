From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 00/09]IPtablestng/Kernel - New Framework For IPtables
Date: Tue, 28 Oct 2008 13:43:46 +0300
Message-ID: <20081028104346.GA31146@ioremap.net>
References: <20081027042834.0BA69C64087@host1.ystp.ac.ir> <20081028000044.GA16721@ioremap.net> <464293e60810280302j26112754o72c1cf3ebd6a0b1f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netfilter-devel <netfilter-devel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jan Engelhardt <jengelh@medozas.de>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Harald Welte <laforge@gnumonks.org>,
	Eric Leblond <eric@inl.fr>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Amin Azez <azez@ufomechanic.net>
To: hamid jafarian <hamid.jafarian@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <464293e60810280302j26112754o72c1cf3ebd6a0b1f@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Tue, Oct 28, 2008 at 01:32:06PM +0330, hamid jafarian (hamid.jafarian@gmail.com) wrote:
> excuse for this loosely patches...
> please more explain...
> do you mean my patches are too long? or ambiguous?
> i 've tried to code base on "Documentation/CodingStyle".. and patch
> base on "how to participate in the kernel community" documents.
> 
> the core of this framework is located at pkt_tables.c&.h (#2&#3 of
> kernel patches).
> iptables.c&.h are completely changed. also at the user space libiptc.c
> is rewritten from scratch thus their patches are really ambiguous to
> be understood..what is the best way to send this patches?
> what this phrase mean: "' remotely match existing code ""?

I mean just coding style: spaces, braces, parentheses, function names
like __something_small_AND_CAPITAL. checkpatch.pl may help, although imo
it should not be followed strickly. It will much simpler to review changes.

-- 
	Evgeniy Polyakov
