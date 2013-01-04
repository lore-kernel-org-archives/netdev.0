From: Michal Simek <monstr@monstr.eu>
Subject: Re: Support for Marvell 88E1510 and 88E1116R
Date: Fri, 4 Jan 2013 10:40:58 +0100
Message-ID: <CAHTX3dKu=1azOvTM7n6M9u8AL_ujkJ5e89SeZG4fV7Q--PEAgA@mail.gmail.com>
References: <50E404BC.3010604@monstr.eu>
	<50E45B74.70301@metafoo.de>
	<BF617F5A412EFC46879ABC89757850DE02692A298149@SERVER.digilent.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Lars-Peter Clausen <lars@metafoo.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Christian Hohnstaedt <chohnstaedt@innominate.com>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	John Linn <linnj@xilinx.com>,
	Sam Bobrowicz <SBobrowicz@digilentinc.com>,
	Rick Hoover <RHoover@digilentinc.com>
To: Steven Wang <steven.wang@digilentinc.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BF617F5A412EFC46879ABC89757850DE02692A298149@SERVER.digilent.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Steve,

2013/1/2 Steven Wang <steven.wang@digilentinc.com>:
> Hi, Michal,
>
> We do have the Ethernet support for 88E1510 (used on ZedBoard) in our repository. The commit is
> https://github.com/Digilent/linux-digilent/commit/ae635e5fff35e9fe5928b4aca7264a1e5313a6b8
> Or, I can send the patch to you if you need.

I know. Can you please clean this patch and send it to mainline for review?
(Remove comment and that emacps connection).

I will add this patch to our tree to support this patch.

Thanks,
Michal


-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian
