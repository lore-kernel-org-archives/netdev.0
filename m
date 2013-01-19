From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH v3] net/hyperv: fix wrong length of mac address
Date: Sat, 19 Jan 2013 15:07:14 +0000
Message-ID: <5fc6e66ddc034250a4e510784266b063@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <20130118083031.GA2303@ppwaskie-mobl2.amr.corp.intel.com>,
 <1358563929-10942-1-git-send-email-kongjianjun@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: Amos Kong <kongjianjun@gmail.com>, "davem@davemloft.net"
 <davem@davemloft.net>, KY Srinivasan <kys@microsoft.com>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1358563929-10942-1-git-send-email-kongjianjun@gmail.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel/>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: "devel" <devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> From: Amos Kong

> Sent: Friday, January 18, 2013 9:52 PM
> To: davem@davemloft.net; KY Srinivasan; Haiyang Zhang
> Cc: netdev@vger.kernel.org; devel@linuxdriverproject.org; Amos Kong
> Subject: [PATCH v3] net/hyperv: fix wrong length of mac address
> 
> This patch fixed wrong mac length, it should be ETH_ALEN,
> also replaced the hardcode 6 in hyperv_net.h
> 
> Signed-off-by: Amos Kong <kongjianjun@gmail.com>
> ---
> v2: update commitlog, fix cc list
> v3: fix hardcode length in hyperv_net.h
> ---

 Acked-by: Haiyang Zhang <haiyangz@microsoft.com>
