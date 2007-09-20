From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [Bug,
 PATCH and another Bug] Was: Fix refcounting problem with
 netif_rx_reschedule()
Date: Thu, 20 Sep 2007 11:12:42 -0700 (PDT)
Message-ID: <20070920.111242.91444191.davem@davemloft.net>
References: <20070919.221224.26966518.davem@davemloft.net>
	<OF035DCEA7.EE6D8D3A-ON6525735C.001FC9D4-6525735C.00206959@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, ossthema@de.ibm.com,
	general@lists.openfabrics.org
To: krkumar2@in.ibm.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <OF035DCEA7.EE6D8D3A-ON6525735C.001FC9D4-6525735C.00206959@in.ibm.com>
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

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Thu, 20 Sep 2007 11:24:01 +0530

> Ran 4/16/64 thread iperf on latest bits with this patch and no issues after
> 30 mins. I used to
> consistently get the bug within 1-2 mins with just 4 threads prior to this
> patch.
> 
> Tested-by: Krishna Kumar <krkumar2@in.ibm.com>
> (if any value in that)

There is much value in that :-)  Thanks a lot Kirshna.
