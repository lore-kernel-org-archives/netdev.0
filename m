From: <raghunathan.venkatesan@wipro.com>
Subject: RE: Unable to handle kernel paging request at virtual address 04000460
Date: Thu, 2 Jun 2005 09:20:21 +0530
Message-ID: <438662DA48DCAA41B1DF648BD4BD76C0E461B8@CHN-SNR-MBX01.wipro.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>,
	<linux@der-keiler.de>
Return-path: <linux-net-owner@vger.kernel.org>
Content-class: urn:content-classes:message
To: <davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,
I understand that the linux community may not be able to debug it for
me. All I require is if people have seen similar problems (the problems
we face are w.r.t to kfree_skb and skb_drop_fraglist crashing due to
some reason, which could be a Memory Management issue or some thing we
are not aware of), then let us know the patches, so that we can try them
out here.

Thankyou for your response.
Regards,
Raghu

-----Original Message-----
From: David S. Miller [mailto:davem@davemloft.net] 
Sent: Thursday, June 02, 2005 12:25 AM
To: Raghunathan Venkatesan (WT01 - EMBEDDED & PRODUCT ENGINEERING
SOLUTIONS)
Cc: linux-net@vger.kernel.org; netdev@oss.sgi.com; linux@der-keiler.de
Subject: Re: Unable to handle kernel paging request at virtual address
04000460


Please don't ask the community to debug your custom kernel with private
VPN driver modules installed.
