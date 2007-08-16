From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
	from the host TCP port space.
Date: Wed, 15 Aug 2007 20:11:15 -0700
Message-ID: <adaabss41ik.fsf@cisco.com>
References: <46B883B5.8040702@opengridcomputing.com>
	<46BB61D0.4090101@opengridcomputing.com>
	<46BB89C0.4040303@ichips.intel.com>
	<20070809.145534.102938208.davem@davemloft.net>
	<46C310E1.7020503@opengridcomputing.com> <46C3B5EF.5060409@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org, David Miller <davem@davemloft.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46C3B5EF.5060409@garzik.org> (Jeff Garzik's message of "Wed,
	15 Aug 2007 22:26:55 -0400")
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

 > Needing to reach out of the RDMA sandbox and reserve net stack
 > resources away from itself travels a path we've consistently avoided.

Where did the idea of an "RDMA sandbox" come from?  Obviously no one
disagrees with keeping things clean and maintainable, but the idea
that RDMA is a second-class citizen that doesn't get any input into
the evolution of the networking code seems kind of offensive to me.

 - R.
