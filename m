From: Srikanth Thokala <srikanth.thokala@xilinx.com>
Subject: RE: [PATCH 2/2] net: emaclite: add barriers to support Xilinx Zynq
 platform
Date: Mon, 2 Dec 2013 10:51:58 +0000
Message-ID: <804ed99e-257a-46b6-b453-86b215ef7309@DB9EHSMHS025.ehs.local>
References: <1385623797-26034-1-git-send-email-sthokal@xilinx.com>
	<9045da6f-88e5-4a20-be68-477790588131@TX2EHSMHS023.ehs.local>
 <20131201.200906.25118738399177322.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Michal Simek <michals@xilinx.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0248.outbound.messaging.microsoft.com ([213.199.154.248]:16176
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753198Ab3LBKwE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Dec 2013 05:52:04 -0500
In-Reply-To: <20131201.200906.25118738399177322.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, December 02, 2013 6:39 AM
> To: Srikanth Thokala
> Cc: netdev@vger.kernel.org; linux-arm-kernel@lists.infradead.org; Michal
> Simek; Srikanth Thokala
> Subject: Re: [PATCH 2/2] net: emaclite: add barriers to support Xilinx Zynq
> platform
>
> From: Srikanth Thokala <srikanth.thokala@xilinx.com>
> Date: Thu, 28 Nov 2013 12:59:57 +0530
>
> > This patch adds barriers at appropriate places to ensure the driver
> > works on Xilinx Zynq ARM-based SoC platform.
> >
> > Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
>
> Memory barriers must have comments.
>
> Specifically, the comment must describe what exactly is being ensured by the
> memory barrier.  What entity must see what memory operations in what order?

Ok. I will update and send you v2.

Thanks
Srikanth



This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.
