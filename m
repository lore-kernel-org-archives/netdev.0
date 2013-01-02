From: Michal Simek <monstr@monstr.eu>
Subject: Support for Marvell 88E1510 and 88E1116R
Date: Wed, 02 Jan 2013 10:58:20 +0100
Message-ID: <50E404BC.3010604@monstr.eu>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christian Hohnstaedt <chohnstaedt@innominate.com>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	John Linn <linnj@xilinx.com>,
	Michal Simek <michal.simek@xilinx.com>
To: Lars-Peter Clausen <lars@metafoo.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:38115 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470Ab3ABJ61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 04:58:27 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so5635779eaa.5
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2013 01:58:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

just a question regarding to Marvell 88e1510 and 88E1116R phys.
We have these phys on the arm zynq board and would like to add
support to the kernel. Is there any repository with these phys?
If yes, when are you going to add them to the mainline?

If there is not, I can send patches for them.
(I am not the author of that patches just trying to clean our
repository and add patches to the mainline)

Thanks,
Michal

-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
