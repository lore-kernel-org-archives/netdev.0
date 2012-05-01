From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 06/15] batman-adv: Distributed ARP Table
 - add snooping functions for ARP messages
Date: Mon, 30 Apr 2012 20:59:04 -0400 (EDT)
Message-ID: <20120430.205904.288157818941040253.davem@davemloft.net>
References: <1335689867-8017-7-git-send-email-ordex@autistici.org>
	<20120430.130555.48557916635285475.davem@davemloft.net>
	<20120430222226.GB21977@ritirata.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20120430222226.GB21977-E/2OGukznS5g9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Date: Tue, 1 May 2012 00:22:30 +0200

> However this patch also contains a procedure which queries the neigh table in
> order to understand whether a given host is known or not.
> Would it be possible to do that in another way (Without manually touching the
> table)?
> 
> Instead, in the next patch (patch 06/15) batman-adv manually increase the neigh
> timeouts. Do you think we should avoid doing that as well? If we are allowed to
> do that, how can we perform the same operation in a cleaner way?
> 
> Last question: why can't other modules use exported functions? Are you going to
> change them as well?

I really don't have time to discuss your neigh issues right now as I'm
busy speaking at conferences and dealing with the backlog of other
patches.

You'll need to find someone else to discuss it with you, sorry.
