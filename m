From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] move ip[6]_queue rerouting up to nf_queue
Date: Tue, 26 Jul 2005 16:56:32 -0700 (PDT)
Message-ID: <20050726.165632.20916615.davem@davemloft.net>
References: <20050726164505.GD4279@rama.de.gnumonks.org>
	<20050726.161300.12130036.davem@davemloft.net>
	<20050726235223.GD4673@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20050726235223.GD4673@rama.de.gnumonks.org>
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
Date: Wed, 27 Jul 2005 01:52:23 +0200

> I'll also prepare a modified version of the nfnetlink module
> refcounting patch, but I'm not submitting it until you've applied ll
> of the other pending netfilter patches since they would conflict
> (re-attached the other two pending patches from earlier today.

No need, see my other email, I took care of this for you.
