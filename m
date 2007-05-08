From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] atl1: use dev_printk macros
Date: Tue, 08 May 2007 01:20:28 -0400
Message-ID: <4640089C.7080900@garzik.org>
References: <11779009311121-git-send-email-jacliburn@bellsouth.net> <11779009313497-git-send-email-jacliburn@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54399 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967880AbXEHFUc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:20:32 -0400
In-Reply-To: <11779009313497-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn wrote:
> Use dev_printk macros for PCI related errors, warnings, debug and info
> console messages.
> 
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> ---
>  drivers/net/atl1/atl1_ethtool.c |   19 +++------
>  drivers/net/atl1/atl1_hw.c      |   22 +++++------
>  drivers/net/atl1/atl1_main.c    |   83 +++++++++++++++++---------------------
>  drivers/net/atl1/atl1_param.c   |   31 +++++++--------
>  4 files changed, 68 insertions(+), 87 deletions(-)

applied 1-2


