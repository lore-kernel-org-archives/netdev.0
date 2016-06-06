From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v4 5/7] net: mdio-mux: Add MDIO mux driver for iProc SoCs
Date: Mon, 6 Jun 2016 11:42:05 -0700
Message-ID: <5755C3FD.9070304@gmail.com>
References: <1465216900-11755-1-git-send-email-pramod.kumar@broadcom.com>
 <1465216900-11755-6-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-arm-kernel@lists.infradead.org
To: Pramod Kumar <pramod.kumar@broadcom.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465216900-11755-6-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/06/2016 05:41 AM, Pramod Kumar wrote:
> iProc based SoCs supports the integrated mdio multiplexer which
> has the bus selection as well as mdio transaction generation logic
> inside.
> 
> This multiplexer has child buses for PCIe, SATA, USB and ETH. These
> buses could be internal or external to SOC where PHYs are attached.
> These buses could use C-45 or C-22 mdio transaction.
> 
> Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
