From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 03/77] infiniband: convert c2 to
	net_device_ops
Date: Sat, 21 Mar 2009 19:34:17 -0700 (PDT)
Message-ID: <20090321.193417.178915231.davem@davemloft.net>
References: <20090321053527.316395697@vyatta.com>
	<20090321053712.797092692@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: shemminger@vyatta.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20090321053712.797092692@vyatta.com>
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

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Mar 2009 22:35:30 -0700

> Convert this driver to new net_device_ops infrastructure.
> Also use default net_device get-stats infrastructure
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
