From: Pradeep Dalvi <pradeep@netxen.com>
Subject: Re: [PATCH 2.6.17 0/9] NetXen: 1G/10G Ethernet Driver
Date: Tue, 22 Aug 2006 00:43:53 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0608220038580.18115@dut46>
References: <Pine.LNX.4.64.0608180713480.6875@dut39>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	"sanjeev@netxen.com" <sanjeev@netxen.com>,
	"unmproj@linsyssoft.com" <unmproj@linsyssoft.com>,
	Rob Mapes <rob@netxen.com>, amitkale@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:60019 "EHLO
	mail.unminc.com") by vger.kernel.org with ESMTP id S932112AbWHVHny
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 03:43:54 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0608180713480.6875@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This updated patch with name prefix changes is available for download at,
http://www.netxen.com/products/downloads/netxen-2.6.17.patch.zip

Thanks and regards,
pradeep

On Fri, 18 Aug 2006, Amit S. Kale wrote:

> Hi,
>
> I'll be sending a NetXen Multi port 1G/10G ethernet driver patch in 
> subsequent emails. This set of patches have changes as per the suggestions, 
> which we received since last post.
>
> Kindly review it and feel free to send feedback.
>
> Thanks,
> -Amit
>
> Signed-off-by: Amit S. Kale <amitkale@netxen.com>
>
> MAINTAINERS                              |    7
> drivers/net/Kconfig                      |    5
> drivers/net/Makefile                     |    1
> drivers/net/netxen/Makefile              |   35
> drivers/net/netxen/netxen_nic.h          |  901 +++++++++++++++++++++++++
> drivers/net/netxen/netxen_nic_ethtool.c  |  696 +++++++++++++++++++
> drivers/net/netxen/netxen_nic_hdr.h      |  611 +++++++++++++++++
> drivers/net/netxen/netxen_nic_hw.c       | 1097 
> ++++++++++++++++++++++++++++++
> drivers/net/netxen/netxen_nic_hw.h       |  500 ++++++++++++++
> drivers/net/netxen/netxen_nic_init.c     | 1090 
> ++++++++++++++++++++++++++++++
> drivers/net/netxen/netxen_nic_ioctl.h    |   75 ++
> drivers/net/netxen/netxen_nic_isr.c      |  300 ++++++++
> drivers/net/netxen/netxen_nic_main.c     | 1107 
> +++++++++++++++++++++++++++++++
> drivers/net/netxen/netxen_nic_niu.c      |  778 +++++++++++++++++++++
> drivers/net/netxen/netxen_nic_phan_reg.h |  195 +++++
> 15 files changed, 7398 insertions(+)
>
>
>
