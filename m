From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] b44: fix manual speed/duplex/autoneg settings
Date: Tue, 20 Jun 2006 04:42:36 -0400
Message-ID: <4497B4FC.8000805@garzik.org>
References: <1150485545.8716.50.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34759 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965146AbWFTImi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 04:42:38 -0400
To: Gary Zambrano <zambrano@broadcom.com>
In-Reply-To: <1150485545.8716.50.camel@dhcp-10-7-81-7.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gary Zambrano wrote:
> Fixes for speed/duplex/autoneg settings and driver settings info.
> This is a redo of a previous patch thanks to feedback from Jeff Garzik.

ACK patches 1-6, but unfortunately failed to apply against latest 
linux-2.6.git:

> [jgarzik@pretzel netdev-2.6]$ git-applymbox /g/tmp/mbox ~/info/signoff.txt
> 6 patch(es) to process.
> 
> Applying 'b44: fix manual speed/duplex/autoneg settings'
> 
> fatal: corrupt patch at line 8


Also, I think I misunderstood the code in our last discussion.  You may 
be right about the advertise-all logic.

	Jeff


