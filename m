From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with
	"alive" pppoe interfaces
Date: Tue, 20 Oct 2009 07:04:35 +0400
Message-ID: <aa79d98a0910192004g43de90d5p823293b888cf0c1d@mail.gmail.com>
References: <200910190002.39937.denys@visp.net.lb>
	 <20091019205740.GD5233@lenovo>
	 <e6d1cecd0910191422t2905d9bbl3355fc50cf36ff90@mail.gmail.com>
	 <200910200308.57381.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michal Ostrowski <mostrows@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <200910200308.57381.denys@visp.net.lb>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/09, Denys Fedoryschenko <denys@visp.net.lb> wrote:
> On Tuesday 20 October 2009 00:22:39 Michal Ostrowski wrote:
>> I'm assuming that there was a race in us sending patches at nearly the
>> same
>> time I'm convinced now that the flush_lock can die, and the patch I sent
>> out kills it.
> o_O
>
> I am drowning in patches. Just let me know which one to test :-)
>
Oh ;) Try out latest Michal's patch (and then mine). I'll continue
digg this issue at next spare time slot. Thanks!
