From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/2] fix NF_QUEUE_NR() macro
Date: Thu, 11 Aug 2005 15:31:36 -0700 (PDT)
Message-ID: <20050811.153136.42907778.davem@davemloft.net>
References: <20050811071320.GB4137@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@gnumonks.org
In-Reply-To: <20050811071320.GB4137@rama.de.gnumonks.org>
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

From: Harald Welte <laforge@gnumonks.org>
Date: Thu, 11 Aug 2005 09:13:21 +0200

> [NETFILTER] Fix NF_QUEUE_NR() macro
> 
> I obviously wanted to use bitwise-or, not logical or.
> 
> Signed-off-by: Harald Welte <laforge@netfilter.org>

Applied.
