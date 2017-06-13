From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v1 1/2] dt-binding: ptp: add bindings document for dte
 based ptp clock
Date: Tue, 13 Jun 2017 07:09:47 +0200
Message-ID: <20170613050947.GA1684@localhost.localdomain>
References: <1497299161-6458-1-git-send-email-arun.parameswaran@broadcom.com>
 <1497299161-6458-2-git-send-email-arun.parameswaran@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com
To: Arun Parameswaran <arun.parameswaran@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1497299161-6458-2-git-send-email-arun.parameswaran@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 12, 2017 at 01:26:00PM -0700, Arun Parameswaran wrote:
> +Example:
> +
> +ptp_dte: ptp_dte@180af650 {
> +	compatible = "brcm,ptp-dte";
> +	reg = <0x180af650 0x10>;
> +	status = "okay";
> +};

This patch set looks okay, as far as it goes, but how does one
actually use the clock?

How does one connect this node to an Ethernet MAC, for example?

Thanks,
Richard
