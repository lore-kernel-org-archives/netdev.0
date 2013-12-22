From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/5] drivers: net: Adding support for APM X-Gene SoC Ethernet base driver
Date: Sun, 22 Dec 2013 10:35:44 +0100
Message-ID: <201312221035.44961.arnd@arndb.de>
References: <1387597376-29303-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Iyappan Subramanian <isubramanian@apm.com>, davem@davemloft.net,
	devicetree@vger.kernel.org, gregkh@linuxfoundation.org,
	patches@apm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jcm@redhat.com,
	Keyur Chudgar <kchudgar@apm.com>, Ravi Patel <rapatel@apm.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387597376-29303-1-git-send-email-isubramanian@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 21 December 2013, Iyappan Subramanian wrote:
> Iyappan Subramanian (5):
>   Documentation: APM X-Gene SoC Ethernet DTS binding documentation
>   arm64: dts: APM X-Gene SoC Ethernet device tree nodes
>   drivers: net: APM X-Gene SoC Ethernet base driver
>   drivers: net: APM X-Gene SoC Ethernet driver error handling
>   drivers: net: APM X-Gene SoC Ethernet driver ethtool support

The third patch (the actual driver) didn't make it to the ARM mailing list.
Maybe it's too large?

	Arnd
