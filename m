From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH] netfilter6: Skip extension headers when matching
 icmp6-type
Date: Fri, 01 Oct 2004 09:19:46 +0900 (JST)
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <200410010019.i910JlZY002193@toshiba.co.jp>
References: <200409301239.i8UCdACm005816@toshiba.co.jp>
	<200409301244.i8UCid17009482@toshiba.co.jp>
	<415C1CC9.2090604@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: okir@suse.de, netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	yasuyuki.kozakai@toshiba.co.jp
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <415C1CC9.2090604@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


Hi,

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 30 Sep 2004 16:48:41 +0200

> >Sorry, I sent it to only netfilter-devel ml because I wanted someone to test
> >it more before sending it to netdev ml.
> >  
> >
> 
> I've reviewed the patch, I think we can push it soon.
> Did you do any changes besides the u_int8_t fix since
> the last patch you sent ?

No.

Regards,

-----------------------------------------------------------------
Yasuyuki KOZAKAI @ USAGI Project <yasuyuki.kozakai@toshiba.co.jp>
