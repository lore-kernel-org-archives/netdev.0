From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 18/34]bnx2x: Reset HW before use
Date: Thu, 22 Jan 2009 15:37:23 +0200
Message-ID: <1232631443.29087.27.camel@lb-tlvb-eliezer>
References: <1231951416.11301.139.camel@lb-tlvb-eliezer>
 <20090117.231706.48278724.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1240 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689AbZAVNie (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 08:38:34 -0500
In-Reply-To: <20090117.231706.48278724.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-01-17 at 23:17 -0800, David Miller wrote:
> From: "Eilon Greenstein" <eilong@broadcom.com>
> Date: Wed, 14 Jan 2009 18:43:36 +0200
> 
> > To avoid complications, make sure that the HW is in reset (as it should be)
> > before trying to take it out of reset. In normal flows, the HW is indeed in rest
> > so this should have no effect
> > 
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> 
> Applied.
> 
Hi Dave,

For some reason, patches 18-21 did not make it to the git (even though
you responded with "Applied" to those 4). I guess that this is what
happen when I send too many patches...

I'm re-sending those 4 after slightly adjusting the lines so it will be
easier to accept with the current net-2.6 (but without any real change
from the previous submit).

Thanks,
Eilon


