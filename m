From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 0/3] add hisilicon hip04 ethernet driver
Date: Tue, 18 Mar 2014 18:27:29 +0800
Message-ID: <53281F91.2030201@huawei.com>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 devicetree@vger.kernel.org
To: Zhangfei Gao <zhangfei.gao@linaro.org>, "David S. Miller"
 <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 2014/3/18 16:40, Zhangfei Gao wrote:
> Zhangfei Gao (3):
>   Documentation: add Device tree bindings for Hisilicon hip04 ethernet
>   net: hisilicon: new hip04 MDIO driver
>   net: hisilicon: new hip04 ethernet driver
> 
>  .../bindings/net/hisilicon-hip04-net.txt           |   74 ++
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/ethernet/hisilicon/Kconfig             |   31 +
>  drivers/net/ethernet/hisilicon/Makefile            |    5 +
>  drivers/net/ethernet/hisilicon/hip04_eth.c         |  717 ++++++++++++++++++++
>  drivers/net/ethernet/hisilicon/hip04_mdio.c        |  190 ++++++
>  7 files changed, 1019 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
>  create mode 100644 drivers/net/ethernet/hisilicon/Kconfig
>  create mode 100644 drivers/net/ethernet/hisilicon/Makefile
>  create mode 100644 drivers/net/ethernet/hisilicon/hip04_eth.c
>  create mode 100644 drivers/net/ethernet/hisilicon/hip04_mdio.c
> 

Great work, thanks for upstream the driver.

Reviewed-by: Ding Tianhong <dingtianhong@huawei.com>
