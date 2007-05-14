From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 does not want to go up (config space problems).
Date: Mon, 14 May 2007 12:20:34 -0700
Message-ID: <1179170434.25622.29.camel@dell>
References: <20070514145419.GA19679@2ka.mipt.ru>
 <1179162923.25622.22.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2611 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756910AbXENScZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 14:32:25 -0400
In-Reply-To: <1179162923.25622.22.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-05-14 at 10:15 -0700, Michael Chan wrote:
> On Mon, 2007-05-14 at 18:54 +0400, Evgeniy Polyakov wrote:
> > This problem never happend before, but suddenly appeared after quite
> > long suspend to disk (several month I think).
> > Nothing was changed in hardware.
> > Both 2.6.18 and 2.6.21-rc3 have the same issue.
> > No interrupts reported in /proc/interrupts.
> 
> I'll look into this.  Thanks.
> 

Suspend/resume worked fine for me on 2.6.21.1 on a similar 5705 device.
I only suspended for a few minutes to mem though.  Does this problem
only happen after a long suspend?

