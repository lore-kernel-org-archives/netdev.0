From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: Re: [ofa-general] Re: Re: Re: [PATCH V3 0/7] net/bonding: ADD IPoIB
	support for	the bonding driver
Date: Wed, 1 Aug 2007 19:10:39 +0300
Message-ID: <20070801161039.GC11758@mellanox.co.il>
References: <46ADDB89.5030601@voltaire.com> <adaejipr3l5.fsf@cisco.com>
	<46AF3CA8.6050201@gmail.com>
	<20070731140436.GA16015@mellanox.co.il>
	<46AF44E0.50700@voltaire.com>
	<20070731142234.GC16015@mellanox.co.il>
	<46B094CA.3080904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>, fubar@us.ibm.com,
	"Michael S. Tsirkin" <mst@dev.mellanox.co.il>,
	general@lists.openfabrics.org, davem@davemloft.net
To: Moni Shoua <monisonlists@gmail.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <46B094CA.3080904@gmail.com>
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

> Quoting Moni Shoua <monisonlists@gmail.com>:
> Subject: Re: [ofa-general] Re: Re: Re: [PATCH V3 0/7] net/bonding: ADD IPoIB support for?the bonding driver
> 
> 
> > It's always wrong to copy symbols from another module without
> > referencing it.
> 
> Michael,
> It seems like the preferred approach is to prevent ib_ipoib from being 
> unloaded while bonding is on top it, right?
> It seems like it would handle all safety issues (not just neigh cleanup).

Donnu about preferred, but that'll work I think.

-- 
MST
