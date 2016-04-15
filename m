From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Fri, 15 Apr 2016 13:22:23 -0500
Message-ID: <5711315F.3000302@codeaurora.org>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <570EC541.6080603@gmail.com> <570FFB6B.5060305@codeaurora.org>
 <57100962.40404@gmail.com> <571012E6.6050303@codeaurora.org>
 <57102920.7000104@codeaurora.org> <20160415164433.GV391@tuxbot>
 <57111E33.606@codeaurora.org> <20160415173529.GY391@tuxbot>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vikram Sethi <vikrams@codeaurora.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, cov@codeaurora.org,
	gavidov@codeaurora.org, Rob Herring <robh+dt@kernel.org>,
	andrew@lunn.ch, Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160415173529.GY391@tuxbot>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn Andersson wrote:
> Your driver is a platform driver and it's being probed from DT. As such
> all this is already taken care of for you, by the core.
>
> The listing is for your reference to know why the dma-ranges property
> would affect your device.

Ah, sorry. I misunderstood what you meant by "you will pass".

Coincidentally, it looks like Lorenzo Pieralisi has posted patches the 
ACPI equivalent just yesterday: https://lkml.org/lkml/2016/4/14/694

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
