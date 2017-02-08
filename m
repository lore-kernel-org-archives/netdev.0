From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] get rid of immrbar_virt_to_phys()
Date: Wed, 08 Feb 2017 13:17:32 -0500 (EST)
Message-ID: <20170208.131732.767256319781283002.davem@davemloft.net>
References: <cover.1486456900.git.christophe.leroy@c-s.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, qiang.zhao@nxp.com, oss@buserror.net,
        linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: christophe.leroy@c-s.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1486456900.git.christophe.leroy@c-s.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Tue,  7 Feb 2017 10:05:07 +0100 (CET)

> ucc_geth ethernet driver is the only driver using immrbar_virt_to_phys() and it uses it incorrectly.
> 
> This patch fixes ucc_geth driver then removes immrbar_virt_to_phys()

Feel free to merge this via whatever tree handles that SOC fsl driver.

Acked-by: David S. Miller <davem@davemloft.net>
