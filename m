From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH] infiniband: Add struct in6_addr addr to
	union ib_gib
Date: Wed, 29 Oct 2008 01:39:02 -0700 (PDT)
Message-ID: <20081029.013902.130933950.davem@davemloft.net>
References: <1225239374.5269.251.camel@localhost>
	<20081028.223941.18931166.davem@davemloft.net>
	<1225263521.5269.273.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org,
	sean.hefty@intel.com, harvey.harrison@gmail.com
To: joe@perches.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1225263521.5269.273.camel@localhost>
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

From: Joe Perches <joe@perches.com>
Date: Tue, 28 Oct 2008 23:58:40 -0700

> On Tue, 2008-10-28 at 22:39 -0700, David Miller wrote:
> > From: Joe Perches <joe@perches.com>
> > Date: Tue, 28 Oct 2008 17:16:14 -0700
> > > ib_gid's can be print'd using the new %p6 facility
> > > Signed-off-by: Joe Perches <joe@perches.com>
> > Joe, please provide something relative to Harvey's patches
> > so that this new union member gets passed into the %p6
> > uses.
> 
> Sure.  After Harvey's patches show up in
> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=summary

They should be there now.
