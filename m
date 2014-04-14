From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH v2 0/4] net: Add APM X-Gene SoC Ethernet driver support
Date: Mon, 14 Apr 2014 14:07:47 +0100
Message-ID: <534BDDA3.3080005@codethink.co.uk>
References: <1397271984-23405-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jcm@redhat.com,
	patches@apm.com, Ravi Patel <rapatel@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397271984-23405-1-git-send-email-isubramanian@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/04/14 04:06, Iyappan Subramanian wrote:
> This patch series adds support for the APM X-Gene SoC Ethernet driver.
>
> v2
> * Completely redesigned ethernet driver
> * Added support to work with big endian kernel
> * Renamed dtb phyid entry to phy_addr
> * Changed dtb local-mac-address entry to byte string format
> * Renamed dtb eth8clk entry to menetclk

Patch 2/4 seems to have vanished?

-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
