From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 7/7] phy: Add Northstar2 PCI Phy support
Date: Fri, 3 Jun 2016 18:29:40 +0200
Message-ID: <20160603162940.GH22120@lunn.ch>
References: <1464967568-27562-1-git-send-email-pramod.kumar@broadcom.com>
 <1464967568-27562-8-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Jon Mason <jonmason@broadcom.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 Kishon Vijay Abraham I <kishon@ti.com>, Rob Herring <robh+dt@kernel.org>,
 bcm-kernel-feedback-list@broadcom.com, Kumar Gala <galak@codeaurora.org>,
 netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org
To: Pramod Kumar <pramod.kumar@broadcom.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1464967568-27562-8-git-send-email-pramod.kumar@broadcom.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 03, 2016 at 08:56:08PM +0530, Pramod Kumar wrote:
> Add PCI Phy support for Broadcom Northstar2 SoCs.  This driver uses the
> interface from the iproc mdio mux driver to enable the devices
> respective phys.
> 
> Signed-off-by: Jon Mason <jonmason@broadcom.com>
> Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Andrew	     
