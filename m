From: Mathieu Olivari <mathieu@codeaurora.org>
Subject: Re: [PATCH 0/7] net: dsa: add QCA AR8xxx switch family support\
Date: Fri, 29 May 2015 11:49:54 -0700
Message-ID: <20150529184951.GA2458@codeaurora.org>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
 <20150529020001.GF11260@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	davem@davemloft.net, f.fainelli@gmail.com, linux@roeck-us.net,
	gang.chen.5i5j@gmail.com, jiri@resnulli.us, leitec@staticky.com,
	fabf@skynet.be, alexander.h.duyck@intel.com,
	pavel.nakonechny@skitlab.ru, joe@perches.com, sfeldma@gmail.com,
	nbd@openwrt.org, juhosg@openwrt.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150529020001.GF11260@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 29, 2015 at 04:00:01AM +0200, Andrew Lunn wrote:
> FYI:
> 
> I have patches which allow DSA to use two cpu interfaces. Seems to
> work on my DIR665 with a Marvell Switch.
> 
> I will post the patches as an RFC.
> 
>   Andrew

Does it require the switch CPU ports to support LAG or is it generic
enough to allow switch partitioning?
