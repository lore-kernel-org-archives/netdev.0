From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] fix loadable module for DPAA Ethernet
Date: Tue, 20 Jun 2017 13:47:10 -0400 (EDT)
Message-ID: <20170620.134710.254847550009401245.davem@davemloft.net>
References: <1497884657-3744-1-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org
To: madalin.bucur@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497884657-3744-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin Bucur <madalin.bucur@nxp.com>
Date: Mon, 19 Jun 2017 18:04:15 +0300

> The DPAA Ethernet makes use of a symbol that is not exported.
> Address the issue by propagating the dma_ops rather than calling
> arch_setup_dma_ops().

Series applied, thanks.
