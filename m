From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: [ofa-general] Re: InfiniBand/RDMA merge plans for 2.6.24
Date: Tue, 18 Sep 2007 19:22:39 +0200
Message-ID: <20070918172239.GA23320@mellanox.co.il>
References: <adahclymos8.fsf@cisco.com> <20070918163433.GL2050@mellanox.co.il>
	<adafy1blwok.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@dev.mellanox.co.il>,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <adafy1blwok.fsf@cisco.com>
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

> Quoting Roland Dreier <rdreier@cisco.com>:
> Subject: Re: InfiniBand/RDMA merge plans for 2.6.24
> 
>  > Roland, could you merge the common TX CQ patch please?
>  > It actually fixes a real problem.
> 
> Yes, I will, but it collides with the net-2.6.24 NAPI rework I think,
> so it may not go in until a few days after the merge window.
> 
> Have you verified that the patch cures the interrupt overload issues?

Yes.

-- 
MST
