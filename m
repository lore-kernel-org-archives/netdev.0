From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [NETFILTER] x_tables
Date: Fri, 13 Jan 2006 14:33:56 -0800 (PST)
Message-ID: <20060113.143356.40119616.davem@davemloft.net>
References: <20060112204734.GQ4430@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20060112204734.GQ4430@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

From: Harald Welte <laforge@netfilter.org>
Date: Thu, 12 Jan 2006 21:47:34 +0100

> Finally, I included all the suggestions/comments for x_tables "take 5",
> ran the nfsim testsuite and feel confident that this is ready for prime
> time.
> 
> Please apply this huge one for 2.6.16,

It's been in my tree since last night, I'll try to see if
I can get Linus to eat this along with TIPC which are the
last two major things I plan to try and merge.

Let's get into bug fix mode people...
