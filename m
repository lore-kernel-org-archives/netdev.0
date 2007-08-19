From: "Sean Hefty" <sean.hefty@intel.com>
Subject: RE: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP portsfrom
	the host TCP port space.
Date: Sun, 19 Aug 2007 00:01:07 -0700
Message-ID: <000001c7e22e$b7b90f00$29c8180a@amr.corp.intel.com>
References: <adafy2hyc04.fsf@cisco.com><20070817.170033.63993876.davem@davemloft.net><adatzqxwh56.fsf@cisco.com>
	<20070817.234405.66176298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org,
	linux-kernel@vger.kernel.org, jeff@garzik.org
To: "'David Miller'" <davem@davemloft.net>,
	<rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070817.234405.66176298.davem@davemloft.net>
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

>Just be realistic and accept that RDMA is a point in time solution,
>and like any other such technology takes flexibility away from users.

All technologies are just point in time solutions.  While management is
important, shouldn't the customers decide how important it is relative to their
problems?  Whether some future technology will be better matters little if a
problem needs to be solved today.

>If you can't see that this is the future, you have my condolences.
>Because frankly, the signs are all around that this is where things
>are going.

Adding a bazillion cores to a processor doesn't do a thing to help memory
bandwidth.

Millions of Infiniband ports are in operation today.  Over 25% of the top 500
supercomputers use Infiniband.  The formation of the OpenFabrics Alliance was
pushed and has been continuously funded by an RDMA customer - the US National
Labs.  RDMA technologies are backed by Cisco, IBM, Intel, QLogic, Sun, Voltaire,
Mellanox, NetApp, AMD, Dell, HP, Oracle, Unisys, Emulex, Hitachi, NEC, Fujitsu,
LSI, SGI, Sandia, and at least two dozen other companies.  IDC expects
Infiniband adapter revenue to triple between 2006 and 2011, and switch revenue
to increase six-fold (combined revenues of 1 billion).

Customers see real benefits using channel based architectures.  Do all customers
need it?  Of course not.  Is it a niche?  Yes, but I would say that about any
10+ gig network.  That doesn't mean that it hasn't become essential for some
customers.

- Sean
