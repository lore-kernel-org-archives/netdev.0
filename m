From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 7/8] infiniband: driver API update
Date: Tue, 06 Jan 2009 10:45:40 -0800 (PST)
Message-ID: <20090106.104540.111119292.davem@davemloft.net>
References: <20090105201442.749889072@vyatta.com>
	<20090105201514.828840735@vyatta.com> <adawsd9mppk.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org,
	shemminger@vyatta.com
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adawsd9mppk.fsf@cisco.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 05 Jan 2009 13:02:15 -0800

> Looks good enough, so Dave if you want to merge it, you can add
> 
> Acked-by: Roland Dreier <rolandd@cisco.com>
> 
> or let me know if you want me to pull it in through my tree.  A couple
> of nits that are probably not worth fixing.  First, globally, it might
> be slightly nicer to merge this as one patch per module, rather than all
> lumped together.  And also:

This is superceded by the 3 patch set Roland took into his tree
so this patch doesn't need to be applied :-)
