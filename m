From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] netvsc: minor fixes and improvements
Date: Fri, 11 Aug 2017 14:00:35 -0700 (PDT)
Message-ID: <20170811.140035.1606948634890959611.davem@davemloft.net>
References: <20170810004612.22163-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, haiyangz@microsoft.com,
 sthemmin@microsoft.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170810004612.22163-1-sthemmin@microsoft.com>
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
Date: Wed,  9 Aug 2017 17:46:02 -0700

> These are non-critical bug fixes, related to functionality now in net-next.
>  1. delaying the automatic bring up of VF device to allow udev to change name.
>  2. performance improvement
>  3. handle MAC address change with VF; mostly propogate the error that VF gives.
>  4. minor cleanups
>  5. allow setting send/receive buffer size with ethtool.

Series applied, thanks Stephen.
