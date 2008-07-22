From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET-NEXT PATCH 1/9] e1000: neaten function declarations
Date: Tue, 22 Jul 2008 19:40:04 -0400
Message-ID: <48866FD4.2010706@garzik.org>
References: <20080711221442.3255.16180.stgit@localhost.localdomain> <20080711221702.3255.43654.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Joe Perches <joe@perches.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49885 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061AbYGVXkI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 19:40:08 -0400
In-Reply-To: <20080711221702.3255.43654.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Joe Perches <joe@perches.com>
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_ethtool.c |  175 +++++-------
>  drivers/net/e1000/e1000_hw.c      |  558 +++++++++++++------------------------
>  drivers/net/e1000/e1000_main.c    |  307 ++++++++------------
>  drivers/net/e1000/e1000_param.c   |   16 -
>  4 files changed, 385 insertions(+), 671 deletions(-)

applied 1-9, after making the obvious fixes to the er32/ew32 patch


