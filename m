From: Lars-Peter Clausen <lars@metafoo.de>
Subject: Re: Support for Marvell 88E1510 and 88E1116R
Date: Wed, 02 Jan 2013 17:08:20 +0100
Message-ID: <50E45B74.70301@metafoo.de>
References: <50E404BC.3010604@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Christian Hohnstaedt <chohnstaedt@innominate.com>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	John Linn <linnj@xilinx.com>,
	Michal Simek <michal.simek@xilinx.com>,
	Sam Bobrowicz <SBobrowicz@digilentinc.com>,
	Rick Hoover <RHoover@digilentinc.com>,
	Steven Wang <steven.wang@digilentinc.com>
To: monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50E404BC.3010604@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/02/2013 10:58 AM, Michal Simek wrote:
> Hi guys,
> 
> just a question regarding to Marvell 88e1510 and 88E1116R phys.
> We have these phys on the arm zynq board and would like to add
> support to the kernel. Is there any repository with these phys?
> If yes, when are you going to add them to the mainline?
> 
> If there is not, I can send patches for them.
> (I am not the author of that patches just trying to clean our
> repository and add patches to the mainline)

I think the 88E1510 support was added by the Digilent guys (added to Cc) and
the 88E1116R support came from within Xilinx.

I agree that these are pretty straight forward changes and could go upstream in
their current form.

- Lars
