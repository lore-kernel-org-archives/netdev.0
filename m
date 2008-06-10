From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] atl1: fix suspend regression
Date: Tue, 10 Jun 2008 18:21:15 -0400
Message-ID: <484EFE5B.6020503@garzik.org>
References: <20080601184441.790521f8@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, csnook@redhat.com, avuton@gmail.com
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38954 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758069AbYFJWVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 18:21:18 -0400
In-Reply-To: <20080601184441.790521f8@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> From: Jay Cliburn <jacliburn@bellsouth.net>
> Date: Sun, 1 Jun 2008 16:57:11 -0500
> Subject: [PATCH] atl1: fix suspend regression
> 
> Using vendor magic to force the PHY into power save mode breaks
> suspend.  It isn't needed anyway, so remove it.
> 
> Tested-by: Avuton Olrich <avuton@gmail.com>
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>

applied


