From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] net: mpc52xx: Use
 platform_register/unregister_drivers()
Date: Thu, 03 Dec 2015 15:15:21 -0500 (EST)
Message-ID: <20151203.151521.1210091390519072265.davem@davemloft.net>
References: <1449073829-12438-1-git-send-email-thierry.reding@gmail.com>
	<1449073829-12438-3-git-send-email-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thierry.reding@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449073829-12438-3-git-send-email-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <thierry.reding@gmail.com>
Date: Wed,  2 Dec 2015 17:30:28 +0100

> From: Thierry Reding <treding@nvidia.com>
> 
> These new helpers simplify implementing multi-driver modules and
> properly handle failure to register one driver by unregistering all
> previously registered drivers.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>

Applied.
