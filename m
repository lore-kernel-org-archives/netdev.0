From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH 0/14] Xilinx axi ethernet patches
Date: Thu, 13 Feb 2014 08:00:10 +0100
Message-ID: <3744167b-7f37-4a86-8569-2a17bd5d3845@CH1EHSMHS035.ehs.local>
References: <cover.1392220536.git.michal.simek@xilinx.com> <20140212.191846.1464564509609498703.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <michal.simek@xilinx.com>, <netdev@vger.kernel.org>,
	<sthokal@xilinx.com>, <devicetree@vger.kernel.org>,
	<monstr@monstr.eu>, <John.Linn@xilinx.com>, <anirudh@xilinx.com>,
	<linux-kernel@vger.kernel.org>, <grant.likely@linaro.org>,
	<robh+dt@kernel.org>, <linux-arm-kernel@lists.infradead.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140212.191846.1464564509609498703.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/13/2014 01:18 AM, David Miller wrote:
> From: Michal Simek <michal.simek@xilinx.com>
> Date: Wed, 12 Feb 2014 16:55:34 +0100
> 
>> I have exctracted patches which I have in our
>> xilinx git tree which are missing in the mainline.
>>
>> The first two patches fix compilation error and
>> warnings. Then 5 feature patches
>> and the rest is OF cleanup and with kernel-doc
>> and checkpatch problems.
> 
> You should not combine bug fix and feature patches.
> 
> Rather, you should submit bug fixes against the 'net' tree.  Then when
> those bug fixes get applied and propagate to the 'net-next' tree you
> can submit the feature patches and cleanups against the 'net-next'
> tree.

Ok. I will.

Thanks,
Michal
