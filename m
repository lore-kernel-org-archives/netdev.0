From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fsl/fman: implement several errata workarounds
Date: Fri, 11 Aug 2017 14:37:55 -0700 (PDT)
Message-ID: <20170811.143755.1486109421287401840.davem@davemloft.net>
References: <1502372824-30180-1-git-send-email-florinel.iordache@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, madalin.bucur@nxp.com,
        linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: florinel.iordache@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502372824-30180-1-git-send-email-florinel.iordache@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florinel Iordache <florinel.iordache@nxp.com>
Date: Thu, 10 Aug 2017 16:47:04 +0300

> Implemented workarounds for the following dTSEC Erratum:
> A002, A004, A0012, A0014, A004839 on several operations
> that involve MAC CFG register changes: adjust link,
> rx pause frames, modify MAC address.
> 
> Signed-off-by: Florinel Iordache <florinel.iordache@nxp.com>

Applied, thanks.
