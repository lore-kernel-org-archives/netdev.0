From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 2/7] binding: Make "mdio-parent-bus" property from
 mandatory to optional
Date: Mon, 6 Jun 2016 16:17:52 +0200
Message-ID: <20160606141752.GN2063@lunn.ch>
References: <1465216900-11755-1-git-send-email-pramod.kumar@broadcom.com>
 <1465216900-11755-3-git-send-email-pramod.kumar@broadcom.com>
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
In-Reply-To: <1465216900-11755-3-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2016 at 06:11:35PM +0530, Pramod Kumar wrote:
> Change "mdio-parent-bus" from mandatory section to optional
> as it won't be required by integrated MDIO multiplexer
> which has bus selection and mdio transaction generation logic,
> integrated inside.
> 
> Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
