From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/4] net: macb: Add support for PTP timestamps in DMA
 descriptors
Date: Tue, 9 May 2017 14:04:34 +0200
Message-ID: <20170509120434.GA9368@localhost.localdomain>
References: <1494321885-14384-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, nicolas.ferre@atmel.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        harini.katakam@xilinx.com, andrei.pistirica@microchip.com
To: Rafal Ozieblo <rafalo@cadence.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1494321885-14384-1-git-send-email-rafalo@cadence.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 09, 2017 at 10:24:45AM +0100, Rafal Ozieblo wrote:
> This patch adds support for PTP timestamps in
> DMA buffer descriptors. It checks capability at runtime
> and uses appropriate buffer descriptor.
> 
> Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>

You posted this series once before, on April 13, 2017.  That makes
this v2.  Please add v2 in the subject line, eg. [PATCH v2 1/4].

Also, add a cover letter [0/4] that summarizes the changes between v1
and v2 of the series.

Thanks,
Richard
