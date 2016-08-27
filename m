From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [v9] net: emac: emac gigabit ethernet controller driver
Date: Fri, 26 Aug 2016 21:29:39 -0700 (PDT)
Message-ID: <20160826.212939.1362447220540461922.davem@davemloft.net>
References: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
        shankerd@codeaurora.org, vikrams@codeaurora.org,
        cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
        andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
        jcm@redhat.com, agross@codeaurora.org, f.fainelli@gmail.com,
        LinoSanfilippo@gmx.de
To: timur@codeaurora.org
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Timur Tabi <timur@codeaurora.org>
Date: Thu, 25 Aug 2016 16:39:03 -0500

> +static const u8 duuid[] = {
> +	0x77, 0x79, 0x60, 0xbf,
> +	0x2d, 0xab,
> +	0x9d, 0x4b,
> +	0x94, 0xf0,
> +	0xe1, 0x11, 0x98, 0x01, 0xa2, 0xba
> +};

This seems to be completely unused, please remove it.
