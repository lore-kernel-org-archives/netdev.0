From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 3/3] netdev/of/phy: Add MDIO bus multiplexer driven
 by GPIO lines.
Date: Mon, 07 May 2012 22:59:00 -0400 (EDT)
Message-ID: <20120507.225900.1607360124849584710.davem@davemloft.net>
References: <1336007799-31016-1-git-send-email-ddaney.cavm@gmail.com>
        <1336007799-31016-4-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, grant.likely@secretlab.ca,
        rob.herring@calxeda.com, devicetree-discuss@lists.ozlabs.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mips@linux-mips.org, afleming@gmail.com,
        galak@kernel.crashing.org, david.daney@cavium.com
To: ddaney.cavm@gmail.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1336007799-31016-4-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney.cavm@gmail.com>
Date: Wed,  2 May 2012 18:16:39 -0700

> From: David Daney <david.daney@cavium.com>
> 
> The GPIO pins select which sub bus is connected to the master.
> 
> Initially tested with an sn74cbtlv3253 switch device wired into the
> MDIO bus.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Applied.
