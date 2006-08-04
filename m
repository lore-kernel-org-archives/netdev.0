From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHSET] Multiple IPV6 Routing Tables & Policy Routing
Date: Fri, 4 Aug 2006 19:41:20 +0200
Message-ID: <20060804174120.GN14627@postel.suug.ch>
References: <20060804102308.711837665@postel.suug.ch> <20060805.005855.08672511.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, davem@davemloft.net, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:2788 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1161292AbWHDRlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 13:41:01 -0400
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20060805.005855.08672511.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@linux-ipv6.org> 2006-08-05 00:58
> In article <20060804102308.711837665@postel.suug.ch> (at Fri, 04 Aug 2006 12:23:08 +0200), Thomas Graf <tgraf@suug.ch> says:
> 
> > This patchset implements multiple IPv6 routing tables and
> > policy routing. Even though the code is almost rewritten
> :
> 
> Thomas, there are some coflicts with current net-2.6 tree.
> Would you please sync with latest net-2.6 tree.

The patches are against the net-2.6.19 tree.
