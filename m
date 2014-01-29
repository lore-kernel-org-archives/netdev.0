From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] DT: net: davinci_emac: couple more properties
 actually optional
Date: Tue, 28 Jan 2014 23:43:15 -0800 (PST)
Message-ID: <20140128.234315.2164810932256158473.davem@davemloft.net>
References: <201401280245.35745.sergei.shtylyov@cogentembedded.com>
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
In-Reply-To: <201401280245.35745.sergei.shtylyov@cogentembedded.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Tue, 28 Jan 2014 02:45:34 +0300

>    Though described as required, couple more properties in the DaVinci EMAC
> binding are actually optional, as the driver will happily function without them.
> The patchset is against DaveM's 'net.git' tree this time.
> 
> [1/2] DT: net: davinci_emac: "ti,davinci-rmii-en" property is actually optional
> [2/2] DT: net: davinci_emac: "ti,davinci-no-bd-ram" property is actually optional

Series applied with the "has/have" thing fixed.

Thanks.
