From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter6: Skip extension headers when matching
	icmp6-type
Date: Thu, 30 Sep 2004 16:48:41 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <415C1CC9.2090604@trash.net>
References: <20040930121620.GH19083@suse.de>
	<200409301239.i8UCdACm005816@toshiba.co.jp>
	<200409301244.i8UCid17009482@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: okir@suse.de, netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
In-Reply-To: <200409301244.i8UCid17009482@toshiba.co.jp>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Yasuyuki Kozakai wrote:

>From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
>Date: Thu, 30 Sep 2004 21:39:09 +0900 (JST)
>
>  
>
>>Thanks. and maybe current kernel has same problem in ip6t_multiport.c, too.
>>But I already sent a patch which fixes this problem to this ml.
>>    
>>
>
>Sorry, I sent it to only netfilter-devel ml because I wanted someone to test
>it more before sending it to netdev ml.
>  
>

I've reviewed the patch, I think we can push it soon.
Did you do any changes besides the u_int8_t fix since
the last patch you sent ?

Regards
Patrick
