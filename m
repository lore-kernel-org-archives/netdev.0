From: "Roland Dreier" <roland.list@gmail.com>
Subject: Re: [ofa-general] Re: [PATCH] infiniband: Add struct in6_addr addr to
	union ib_gib
Date: Wed, 29 Oct 2008 11:15:47 -0700
Message-ID: <f8ca0a150810291115r79924e8bw162cbf72510065af@mail.gmail.com>
References: <ada8ws8mi8x.fsf@cisco.com> <1225236128.5269.240.camel@localhost>
	<1225239374.5269.251.camel@localhost>
	<20081028.223941.18931166.davem@davemloft.net>
	<1225263521.5269.273.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org,
	David Miller <davem@davemloft.net>, harvey.harrison@gmail.com
To: "Joe Perches" <joe@perches.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1225263521.5269.273.camel@localhost>
Content-Disposition: inline
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

> Sure.  After Harvey's patches show up in
> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=summary
> I'll make a patchset including this union ib_gid addition as
> well as changes to drivers/infiniband/

OK I guess.  I also don't have any objection to using a different
format letter but the
same underlying code as the p6 implementation as an alternative for handling
the type checking.

> Roland, in a separate question, are the infiniband maintainers
> also the maintainers of include/rdma/?  If "F: patterns" ever
> gets accepted into MAINTAINERS, should include/rdma/ be listed
> under infiniband?

Yes, drivers/infiniband and include/rdma are all part of the
InfiniBand/RDMA stack.
