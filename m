From: George Cherian <george.cherian@ti.com>
Subject: Re: [PATCH 4/6] drivers: net: cpsw: Enable Annexe F Time sync
Date: Mon, 28 Apr 2014 18:28:07 +0530
Message-ID: <535E505F.3010302@ti.com>
References: <1398658225-25873-1-git-send-email-george.cherian@ti.com> <1398658225-25873-5-git-send-email-george.cherian@ti.com> <20140428075530.GA8371@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<davem@davemloft.net>, <jeffrey.t.kirsher@intel.com>,
	<dborkman@redhat.com>, <ast@plumgrid.com>, <tklauser@distanz.ch>,
	<mpa@pengutronix.de>, <bhutchings@solarflare.com>,
	<zonque@gmail.com>, <balbi@ti.com>, <mugunthanvnm@ti.com>,
	<t-kristo@ti.com>, <mturquette@linaro.org>,
	<linux@arm.linux.org.uk>, <galak@codeaurora.org>,
	<ijc+devicetree@hellion.org.uk>, <mark.rutland@arm.com>,
	<pawel.moll@arm.com>, <robh+dt@kernel.org>, <tony@atomide.com>,
	<bcousson@baylibre.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140428075530.GA8371@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/28/2014 1:25 PM, Richard Cochran wrote:
> On Mon, Apr 28, 2014 at 09:40:23AM +0530, George Cherian wrote:
>> Enable the Annex F Time Sync explicitly for DRA7x and AM4372.
>> With this enabled the L2 PTP is working.
> L2 works fine without this bit. If this is needed for V3 hardware,
> then it should have its own code variant.
okay
>   
>> while at that rename TS_BIT8 to TS_TTL_NONZERO
> Is this bit finally documented for am335x?
Not for am335x, but for other SoC's it s documented.
> Thanks,
> Richard
>


-- 
-George
