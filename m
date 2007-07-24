From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/5] atl1: change tpd_avail function name
Date: Tue, 24 Jul 2007 16:36:59 -0400
Message-ID: <46A662EB.6070707@garzik.org>
References: <1184888714454-git-send-email-jacliburn@bellsouth.net> <1184888714650-git-send-email-jacliburn@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net, csnook@redhat.com
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58988 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757944AbXGXUhC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 16:37:02 -0400
In-Reply-To: <1184888714650-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn wrote:
> Change tpd_avail() to atl1_tpd_avail().
> 
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> ---
>  drivers/net/atl1/atl1_main.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)

applied 1-5


