From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH net-2.6.24] Fix refcounting problem with
 netif_rx_reschedule()
Date: Tue, 18 Sep 2007 15:50:51 -0700 (PDT)
Message-ID: <20070918.155051.122059976.davem@davemloft.net>
References: <adawsunkg8i.fsf@cisco.com>
	<20070918.131505.91210517.davem@davemloft.net>
	<adaodfzk2wj.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adaodfzk2wj.fsf@cisco.com>
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
Date: Tue, 18 Sep 2007 15:46:36 -0700

> OK, I actually have a system with a ppc 440 SoC that uses this driver,
> so I'll try to get things to the stage where I can boot net-2.6.24 on
> it and see if I can get the driver working...

Thanks a lot Roland.
