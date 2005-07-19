From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] BRIDGE_EBT_ARPREPLY must depend on INET
Date: Tue, 19 Jul 2005 14:00:24 -0700 (PDT)
Message-ID: <20050719.140024.131914996.davem@davemloft.net>
References: <20050719135529.GH5031@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org, coreteam@netfilter.org,
	bridge@osdl.org, shemminger@osdl.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: bunk@stusta.de
In-Reply-To: <20050719135529.GH5031@stusta.de>
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

From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 19 Jul 2005 15:55:29 +0200

> BRIDGE_EBT_ARPREPLY=y and INET=n results in the following compile error:

Applied, thanks Adrian.
