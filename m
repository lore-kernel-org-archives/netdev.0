From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] DT: net: davinci_emac: "phy-handle" property is
 actually optional
Date: Sun, 19 Jan 2014 20:04:11 -0800 (PST)
Message-ID: <20140119.200411.1357790885368672921.davem@davemloft.net>
References: <201401170132.14479.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, rob@landley.net, devicetree@vger.kernel.org,
	linux-doc@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <201401170132.14479.sergei.shtylyov@cogentembedded.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 17 Jan 2014 01:32:13 +0300

> Though described as required, the "phy-handle" property for the DaVinci EMAC
> binding is actually optional, as the driver will happily function without it,
> assuming 100/FULL link; the property is not specified  either in the example
> device node,  or in the actual EMAC device nodes for DA850 and AM3517 device
> trees.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
