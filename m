From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,v3] tools: hv: Add a script to help bonding
 synthetic and VF NICs
Date: Tue, 12 Jul 2016 10:42:05 -0700 (PDT)
Message-ID: <20160712.104205.1794908532241720091.davem@davemloft.net>
References: <1468282002-19723-1-git-send-email-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, olaf@aepfle.de,
 driverdev-devel@linuxdriverproject.org
To: haiyangz@microsoft.com, haiyangz@exchange.microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1468282002-19723-1-git-send-email-haiyangz@exchange.microsoft.com>
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

From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Date: Mon, 11 Jul 2016 17:06:42 -0700

> From: Haiyang Zhang <haiyangz@microsoft.com>
> 
> This script helps to create bonding network devices based on synthetic NIC
> (the virtual network adapter usually provided by Hyper-V) and the matching
> VF NIC (SRIOV virtual function). So the synthetic NIC and VF NIC can
> function as one network device, and fail over to the synthetic NIC if VF is
> down.
> 
> Mayjor distros (RHEL, Ubuntu, SLES) supported by Hyper-V are supported by
> this script.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
