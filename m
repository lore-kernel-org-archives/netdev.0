From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] atl1: add PHY power save mode
Date: Tue, 13 May 2008 01:14:59 -0400
Message-ID: <482923D3.8060100@garzik.org>
References: <1210389129-3868-1-git-send-email-jacliburn@bellsouth.net> <1210389129-3868-2-git-send-email-jacliburn@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	csnook@redhat.com, pelle@dsv.su.se
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49314 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754656AbYEMFPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 01:15:06 -0400
In-Reply-To: <1210389129-3868-2-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> Using vendor-provided magic, add code to enter power save mode
> on the PHY.  We'll need this for suspend and wake-on-lan.
> 
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> ---
>  drivers/net/atlx/atl1.c |   19 ++++++++-----------
>  drivers/net/atlx/atlx.h |    3 +++
>  2 files changed, 11 insertions(+), 11 deletions(-)

applied 1-4


