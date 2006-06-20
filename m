From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: Re: [PATCH 1/6] b44: fix manual speed/duplex/autoneg settings
Date: Tue, 20 Jun 2006 15:34:09 -0700
Message-ID: <1150842849.21197.51.camel@dhcp-10-7-81-7.broadcom.com>
References: <1150485545.8716.50.camel@dhcp-10-7-81-7.broadcom.com>
 <4497B4FC.8000805@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:63242 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751436AbWFTWeq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 18:34:46 -0400
To: "Jeff Garzik" <jeff@garzik.org>
In-Reply-To: <4497B4FC.8000805@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-06-20 at 04:42 -0400, Jeff Garzik wrote:

> ACK patches 1-6, but unfortunately failed to apply against latest 
> linux-2.6.git:
> 
> > [jgarzik@pretzel netdev-2.6]$ git-applymbox /g/tmp/mbox ~/info/signoff.txt
> > 6 patch(es) to process.
> > 
> > Applying 'b44: fix manual speed/duplex/autoneg settings'
> > 
> > fatal: corrupt patch at line 8

Sorry about that. 
They patch ok when using patch, however, the apply failure appears to be
related to me using git-stripspace on the patches before submitting
them.

I am resending patches that have not been git-stripspaced, so you should
not have the apply problem with the resend patches.

Thanks.

