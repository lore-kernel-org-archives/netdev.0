From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.4] 2/2:  Fix NAT helper locking
Date: Fri, 3 Sep 2004 00:27:12 -0700
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040903002712.4fdf8194.davem@davemloft.net>
References: <20040903070455.GS26263@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040903070455.GS26263@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Fri, 3 Sep 2004 09:04:55 +0200
Harald Welte <laforge@netfilter.org> wrote:

> This is the second of a two part patch.
> 
> This part fixes the locking in NAT helpers.

These 2.4.x variants of the NAT locking fixes
are applied as well.

Thanks.
