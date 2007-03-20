From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Tue, 20 Mar 2007 16:34:56 -0700 (PDT)
Message-ID: <20070320.163456.41638776.davem@davemloft.net>
References: <20070319151336.GA24225@mellanox.co.il>
	<20070319232043.GA23359@ms2.inr.ac.ru>
	<20070320160217.GC31495@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: mst@dev.mellanox.co.il
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070320160217.GC31495@mellanox.co.il>
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

From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Date: Tue, 20 Mar 2007 18:02:17 +0200

> David, Alexey, what do you think about this patch? Is it right?
> Could this patch be considered for 2.6.21?
> 
> Acked-by: Michael S. Tsirkin <mst@dev.mellanox.co.il>

I plan to apply it and merge.
