From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: [PATCH 2.6] iptables CONNMARK match+target
Date: Thu, 21 Oct 2004 09:12:48 +0200 (CEST)
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <Pine.LNX.4.61.0410210912280.18310@filer.marasystems.com>
References: <20041020222102.GO19899@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Linux Netdev List <netdev@oss.sgi.com>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20041020222102.GO19899@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004, Harald Welte wrote:

> This is the first patch, adding something similar like nfmark, but on a
> per-conntrack (as opposed to per-skb) level.  Very useful especially for
> asymmatric routing in combination with MASQUERADE, as often found on
> home DSL setups with dymamic IP address that also have e.g. a tunnel
> device with static IP.

Is this with or without the mark operations?

Regards
Henrik
