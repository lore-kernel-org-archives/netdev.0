From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 2/3] netdev/of/phy: Add MDIO bus multiplexer support.
Date: Sat, 21 Apr 2012 19:03:35 -0400 (EDT)
Message-ID: <20120421.190335.1197591560590885057.davem@davemloft.net>
References: <1334791254-15987-3-git-send-email-ddaney.cavm@gmail.com>
        <20120421.153201.2103447307695063734.davem@davemloft.net>
        <4F9325DF.7020003@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ddaney.cavm@gmail.com, grant.likely@secretlab.ca,
        rob.herring@calxeda.com, devicetree-discuss@lists.ozlabs.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mips@linux-mips.org, afleming@gmail.com,
        galak@kernel.crashing.org, david.daney@cavium.com
To: david.s.daney@gmail.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <4F9325DF.7020003@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.s.daney@gmail.com>
Date: Sat, 21 Apr 2012 14:25:51 -0700

> If we were to specify the dependencies in both places, we gain nothing
> other than duplication of information.

Each Kconfig option enabling a module has to have appropriate
dependencies.
