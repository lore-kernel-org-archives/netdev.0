From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 0/9] ARM: Berlin: Ethernet support
Date: Tue, 23 Sep 2014 14:41:47 +0200
Message-ID: <3200502.7xjfrZcKCM@wuerfel>
References: <1411474536-22626-1-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	sebastian.hesselbarth@gmail.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
	jszhang@marvell.com
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411474536-22626-1-git-send-email-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 23 September 2014 14:15:27 Antoine Tenart wrote:
> 
> This series introduce support for the Ethernet controller on Berlin SoCs,
> using the existing pxa168 Ethernet driver. In order to do this, DT
> support is added to the driver alongside some other modifications and
> fixes.
> 

Looks great overall, I've commented on two issues I've found, but only
the phy-addr one really needs to be addressed. Once that is out of the
way, please add

Acked-by: Arnd Bergmann <arnd@arndb.de>
