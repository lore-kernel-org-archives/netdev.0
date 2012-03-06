From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] powerpc/44x: Add more changes for APM821XX EMAC
 driver
Date: Tue, 06 Mar 2012 17:08:28 -0500 (EST)
Message-ID: <20120306.170828.2286313308907964046.davem@davemloft.net>
References: <1330920224-3006-1-git-send-email-dhdang@apm.com>
	<1330945102-15802-1-git-send-email-dhdang@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, paulus@samba.org, jwboyer@gmail.com,
	sr@denx.de, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dhdang@apm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330945102-15802-1-git-send-email-dhdang@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Duc Dang <dhdang@apm.com>
Date: Mon,  5 Mar 2012 17:58:22 +0700

>  This patch includes:
> 
>   Configure EMAC PHY clock source (clock from PHY or internal clock).
> 
>   Do not advertise PHY half duplex capability as APM821XX EMAC does not support half duplex mode.
> 
>   Add changes to support configuring jumbo frame for APM821XX EMAC.
> 
> Signed-off-by: Duc Dang <dhdang@apm.com>

Applied with coding style fixes.
