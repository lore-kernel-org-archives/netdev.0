From: Michal Simek <monstr@monstr.eu>
Subject: Re: Support for Marvell 88E1510 and 88E1116R
Date: Tue, 8 Jan 2013 09:51:47 +0100
Message-ID: <CAHTX3dKKO05Th3c5KH+azjq_b772ZsWLN8Yox_p2WtzN7hemdA@mail.gmail.com>
References: <50E404BC.3010604@monstr.eu>
	<50E45B74.70301@metafoo.de>
	<BF617F5A412EFC46879ABC89757850DE02692A298149@SERVER.digilent.local>
	<CAHTX3dKu=1azOvTM7n6M9u8AL_ujkJ5e89SeZG4fV7Q--PEAgA@mail.gmail.com>
	<BF617F5A412EFC46879ABC89757850DE02692A29839D@SERVER.digilent.local>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:41916 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755017Ab3AHIvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 03:51:48 -0500
Received: by mail-ie0-f177.google.com with SMTP id k13so179568iea.36
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 00:51:47 -0800 (PST)
In-Reply-To: <BF617F5A412EFC46879ABC89757850DE02692A29839D@SERVER.digilent.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2013/1/4 Steven Wang <steven.wang@digilentinc.com>:
> Hi, Michal,
>
> I have generated the patch and cleaned up the codes.
> The codes was originally written by Rick Hoover.
>
> I have sent it via git send-email command to you and git@xilinx.com.
> I also attached the patch here just in case the email failed to go through.

FYI: please use git send-email for sending this patch to netdev
mailing list too.

Thanks,
Michal

-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian
