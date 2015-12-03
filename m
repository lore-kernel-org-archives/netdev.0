From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: bfin_mac: Use
 platform_register/unregister_drivers()
Date: Thu, 03 Dec 2015 15:15:10 -0500 (EST)
Message-ID: <20151203.151510.1478021142871679395.davem@davemloft.net>
References: <1449073829-12438-1-git-send-email-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thierry.reding@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449073829-12438-1-git-send-email-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <thierry.reding@gmail.com>
Date: Wed,  2 Dec 2015 17:30:26 +0100

> From: Thierry Reding <treding@nvidia.com>
> 
> These new helpers simplify implementing multi-driver modules and
> properly handle failure to register one driver by unregistering all
> previously registered drivers.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>

Applied.
