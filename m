From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 1/7] mdio: mux: Enhanced MDIO mux framework for
 integrated multiplexers
Date: Mon, 6 Jun 2016 16:17:28 +0200
Message-ID: <20160606141728.GM2063@lunn.ch>
References: <1465216900-11755-1-git-send-email-pramod.kumar@broadcom.com>
 <1465216900-11755-2-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-arm-kernel@lists.infradead.org
To: Pramod Kumar <pramod.kumar@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465216900-11755-2-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2016 at 06:11:34PM +0530, Pramod Kumar wrote:
> An integrated multiplexer uses same address space for
> "muxed bus selection" and "generation of mdio transaction"
> hence its good to register parent bus from mux driver.
> 
> Hence added a mechanism where mux driver could register a
> parent bus and pass it down to framework via mdio_mux_init api.
> 
> Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

     Andrew
