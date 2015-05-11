From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH] net: ll_temac: Use one return statement instead of two
Date: Mon, 11 May 2015 16:05:33 +0200
Message-ID: <5550B72D.2020004@xilinx.com>
References: <b10b8e1e696a09152b9df535a8bd37e6500ac1c7.1431005352.git.michal.simek@xilinx.com>
 <alpine.DEB.2.10.1505071730090.2462@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Michal Simek <monstr@monstr.eu>,
	=?windows-1252?Q?S=F6ren_Brinkmann?= <soren.brinkmann@xilinx.com>,
	"Fabian Frederick" <fabf@skynet.be>,
	<linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	=?windows-1252?Q?Manuel_Sch=F6lling?= <manuel.schoelling@gmx.de>,
	Markus Elfring <elfring@users.sourceforge.net>,
	Subbaraya Sundeep Bhatta <subbaraya.sundeep.bhatta@xilinx.com>,
	<linux-arm-kernel@lists.infradead.org>
To: Julia Lawall <julia.lawall@lip6.fr>,
	Michal Simek <michal.simek@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1505071730090.2462@hadrien>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/07/2015 05:30 PM, Julia Lawall wrote:
> On Thu, 7 May 2015, Michal Simek wrote:
> 
>> From: Michal Simek <monstr@monstr.eu>
>>
>> Use one return statement instead of two to simplify the code.
>> Both are returning the same value.
>>
>> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
> 
> The from should be the same as the signed off.  You need From if you want
> something different than what is naturally put by your mailer.  But that
> doesn't see to be the case.

ok. Fixed in v2.

Thanks,
Michal
