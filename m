From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] fix deadlock with ip_queue and tcp local input path
Date: Thu, 26 May 2005 13:52:29 -0700 (PDT)
Message-ID: <20050526.135229.111208218.davem@davemloft.net>
References: <20050526142420.GD13114@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20050526142420.GD13114@sunbeam.de.gnumonks.org>
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
Date: Thu, 26 May 2005 16:24:21 +0200

> Dave: Please don't apply yet, I want to receive feedback from the
> netfilter developers first.  I'm just Cc'ing netdev in case somebody
> wants an intermediate fix to fix the problem.

OK.
