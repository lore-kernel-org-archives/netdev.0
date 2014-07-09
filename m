From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH NET-NEXT V2] netxen: fix ethtool rx_dropped information
 in ethtool get_ethtool_stats()
Date: Wed, 9 Jul 2014 06:30:36 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A46FEEF8B@avmb2.qlogic.org>
References: <1404827830-22990-1-git-send-email-ethan.zhao@oracle.com>
 <53BCABD3.3050207@oracle.com>
 <20140708.204602.1475610247455018529.davem@davemloft.net>
 <53BCCFE1.5000806@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "balbi@ti.com" <balbi@ti.com>, netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"sriharsha.devdas@oracle.com" <sriharsha.devdas@oracle.com>,
	"ethan.kernel@gmail.com" <ethan.kernel@gmail.com>,
	"vaughan.cao@oracle.com" <vaughan.cao@oracle.com>
To: ethan zhao <ethan.zhao@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:30727 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751054AbaGIGam convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2014 02:30:42 -0400
In-Reply-To: <53BCCFE1.5000806@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of ethan zhao
> Sent: Wednesday, July 09, 2014 10:45 AM
> To: David Miller
> Cc: balbi@ti.com; netdev; linux-kernel; sriharsha.devdas@oracle.com;
> ethan.kernel@gmail.com; vaughan.cao@oracle.com
> Subject: Re: [PATCH NET-NEXT V2] netxen: fix ethtool rx_dropped
> information in ethtool get_ethtool_stats()
> 
> David,
>      Sorry I don't know who owns this driver, the SOB of other patches to
> netxen may mislead me you could ACK it or not,  so it is definitely not the
> original meaning that ask you specifically to review one patch.
> just ask for help point to someone could review it

Ethan,

You can get the maintainers of netxen_nic driver from " MAINTAINERS" file.
Please copy maintainers of this driver for review.

NETXEN (1/10) GbE SUPPORT
M:      Manish Chopra <manish.chopra@qlogic.com>
M:      Sony Chacko <sony.chacko@qlogic.com>
M:      Rajesh Borundia <rajesh.borundia@qlogic.com>
L:      netdev@vger.kernel.org
W:      http://www.qlogic.com
S:      Supported
F:      drivers/net/ethernet/qlogic/netxen/


HTH.

Thanks,
Shahed
