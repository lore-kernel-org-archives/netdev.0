From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 7/9] mlx4_en: Always allocate RX ring for
 each completion vector
Date: Thu, 25 Dec 2008 18:21:42 -0800 (PST)
Message-ID: <20081225.182142.18371433.davem@davemloft.net>
References: <494F6573.2070405@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org,
	jeff@garzik.org
To: yevgenyp@mellanox.co.il
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <494F6573.2070405@mellanox.co.il>
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

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 22 Dec 2008 12:01:23 +0200

> Removed module parameter specifying number of rings.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Since patch 4 didn't apply this one won't either.

See what a waste of time it is when you submit patches
that don't apply?  There is a domino effect on the rest
of the patches in the series since several if not all
of them will fail to apply as well.
