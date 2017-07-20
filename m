From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] netvsc: lockdep and related fixes
Date: Wed, 19 Jul 2017 22:20:54 -0700 (PDT)
Message-ID: <20170719.222054.645006744379827912.davem@davemloft.net>
References: <20170719185319.25871-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, haiyangz@microsoft.com,
 sthemmin@microsoft.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170719185319.25871-1-sthemmin@microsoft.com>
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

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 19 Jul 2017 11:53:11 -0700

> These fix sparse and lockdep warnings from netvsc driver.
> Targeting these at net-next since no actual related failures
> have been observed in non-debug kernels.

Series applied, thanks Stephen.
