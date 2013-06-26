From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH v8] ethernet/arc/arc_emac - Add new driver
Date: Wed, 26 Jun 2013 14:19:12 +0530
Message-ID: <51CAAB08.106@synopsys.com>
References: <1372053267-19359-1-git-send-email-abrodkin@synopsys.com> <20130625.163452.653163641005496729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<andy.shevchenko@gmail.com>, <romieu@fr.zoreil.com>,
	<joe@perches.com>, <Vineet.Gupta1@synopsys.com>,
	<Mischa.Jonker@synopsys.com>, <arnd@arndb.de>,
	<grant.likely@linaro.org>, <rob.herring@calxeda.com>,
	<paul.gortmaker@windriver.com>, <linux-kernel@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>, <florian@openwrt.org>,
	<david.laight@aculab.com>
To: <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130625.163452.653163641005496729.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/26/2013 05:04 AM, David Miller wrote:
> From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
> Date: Mon, 24 Jun 2013 09:54:27 +0400
>
>> Driver for non-standard on-chip ethernet device ARC EMAC 10/100,
>> instantiated in some legacy ARC (Synopsys) FPGA Boards such as
>> ARCAngel4/ML50x.
>>
>> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
> Applied to net-next, thanks.

Alexey, can you please send the DT updates for arch/arc to instantiate this as well

-Vineet
