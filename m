From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [Patch]: IPv6 Connection Tracking
Date: Thu, 25 Sep 2003 22:10:04 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309251310.WAA20555@toshiba.co.jp>
References: <200309250521.OAA29293@toshiba.co.jp>
	<20030925092806.GC5758@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yasuyuki.kozakai@toshiba.co.jp, coreteam@netfilter.org,
        netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@netfilter.org
In-Reply-To: <20030925092806.GC5758@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi, Harald.

Thank you for your concern, and I understand what you say.

> To summarize, I see the following options:
> 
> 1) submit ip6_conntrack to the 2.6.x kernel
>    We would then need somebody committe to maintaining it, assuring
>    it keeps in sync with the work done on ip_conntrack.  I do not want
>    to put the burden of ip_conntrack / ip6_conntrack synchronization on
>    everybody who submits patches/bugfixes/...
> 
> 2) keep ip6_conntrack in patch-o-matic and start work on a l3
>    independent conntrack system.
>    This would give more users to the code, since most advanced 
>    netfilter users are using patch-o-matic anyway.
> 

I interested on a L3 independent connection tracking.
Could you show me about concrete loadmap and the scheme of nf_conntrack ?

----------------------------------------
Yasuyuki KOZAKAI

Communication Platform Laboratory,
Corporate Research & Development Center,
Toshiba Corporation

yasuyuki.kozakai@toshiba.co.jp
----------------------------------------
