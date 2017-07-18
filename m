From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Convert to using %pOF instead of full_name
Date: Tue, 18 Jul 2017 14:51:46 -0700 (PDT)
Message-ID: <20170718.145146.1983238254018568174.davem@davemloft.net>
References: <20170718214339.7774-39-robh@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, madalin.bucur@nxp.com,
        dougmill@linux.vnet.ibm.com, grygorii.strashko@ti.com,
        michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: robh@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170718214339.7774-39-robh@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <robh@kernel.org>
Date: Tue, 18 Jul 2017 16:43:19 -0500

> Now that we have a custom printf format specifier, convert users of
> full_name to use %pOF instead. This is preparation to remove storing
> of the full path string for each node.
> 
> Signed-off-by: Rob Herring <robh@kernel.org>

Acked-by: David S. Miller <davem@davemloft.net>
