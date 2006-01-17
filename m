From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] fix ip[6]t_policy compiler warnings after x_tables merge
Date: Tue, 17 Jan 2006 02:26:53 -0800 (PST)
Message-ID: <20060117.022653.31779881.davem@davemloft.net>
References: <20060114204052.GF6740@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20060114204052.GF6740@sunbeam.de.gnumonks.org>
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
Date: Sat, 14 Jan 2006 21:40:53 +0100

> [NETFILTER] ip[6]t_policy: Fix compilation warnings
> 
> ip[6]t_policy argument conversion slipped when merging with x_tables
> 
> Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
> Signed-off-by: Harald Welte <laforge@netfilter.org>

Applied, thanks.
