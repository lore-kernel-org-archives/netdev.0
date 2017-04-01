From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dpaa_eth: use AVOIDBLOCK for Tx confirmation queues
Date: Sat, 01 Apr 2017 12:04:10 -0700 (PDT)
Message-ID: <20170401.120410.2118230452760689948.davem@davemloft.net>
References: <1490880255-13503-1-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org
To: madalin.bucur@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490880255-13503-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin Bucur <madalin.bucur@nxp.com>
Date: Thu, 30 Mar 2017 16:24:15 +0300

> The AVOIDBLOCK flag determines the Tx confirmation queues processing
> to be redirected to any available CPU when the current one is slow
> in processing them. This may result in a higher Tx confirmation
> interrupt count but may reduce pressure on a certain CPU that with
> the previous setting would process all Tx confirmation frames.
> 
> Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>

Applied, thanks.
