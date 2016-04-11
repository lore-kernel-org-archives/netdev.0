From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] drivers: net: cpsw: fix ale calls and drop
 host_port field from cpsw_priv
Date: Mon, 11 Apr 2016 15:12:29 -0400 (EDT)
Message-ID: <20160411.151229.7068975173395002.davem@davemloft.net>
References: <1460031404-28594-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com, nsekhar@ti.com,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460031404-28594-1-git-send-email-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Thu, 7 Apr 2016 15:16:42 +0300

> This clean up series intended to:
>  - fix port_mask parameters in ale calls and drop unnecessary shifts
>  - drop host_port field from struct cpsw_priv
> 
> Nothing critical. Tested on am437x-idk-evm in dual mac and switch modes.

Looks good, series applied, thanks.
