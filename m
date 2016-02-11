From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] hv_netvsc: cleanup netdev feature flags
 for netvsc
Date: Thu, 11 Feb 2016 07:18:25 -0500 (EST)
Message-ID: <20160211.071825.110405374981021993.davem@davemloft.net>
References: <1454629774-22257-1-git-send-email-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: sixiao@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1454629774-22257-1-git-send-email-sixiao@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Simon Xiao <sixiao@microsoft.com>
Date: Thu,  4 Feb 2016 15:49:34 -0800

> 1. Adding NETIF_F_TSO6 feature flag;
> 2. Adding NETIF_F_HW_CSUM. NETIF_F_IPV6_CSUM and NETIF_F_IP_CSUM are 
> being deprecated;
> 3. Cleanup the coding style of flag assignment by using macro.
> 
> Signed-off-by: Simon Xiao <sixiao@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied, thanks.
