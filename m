From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v1 1/1] dt-binding: ptp: Add SoC compatibility strings
 for dte ptp clock
Date: Mon, 10 Jul 2017 08:44:37 -0500
Message-ID: <20170710134437.ribkgkpwf2hlvelv@rob-hp-laptop>
References: <1499362677-28579-1-git-send-email-arun.parameswaran@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Richard Cochran <richardcochran@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com
To: Arun Parameswaran <arun.parameswaran@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1499362677-28579-1-git-send-email-arun.parameswaran@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 06, 2017 at 10:37:57AM -0700, Arun Parameswaran wrote:
> Add SoC specific compatibility strings to the Broadcom DTE
> based PTP clock binding document.
> 
> Fixed the document heading and node name.
> 
> Fixes: 80d6076140b2 ("dt-binding: ptp: add bindings document for dte based ptp clock")
> Signed-off-by: Arun Parameswaran <arun.parameswaran@broadcom.com>
> ---
>  Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt | 15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)

Acked-by: Rob Herring <robh@kernel.org>
