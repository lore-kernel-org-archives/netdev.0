From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 15:22:39 -0700 (PDT)
Message-ID: <20060928.152239.15408691.davem@davemloft.net>
References: <451C28E9.6040708@intel.com>
	<20060928.145345.90823467.davem@davemloft.net>
	<1159481020.3741.16.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, shemminger@osdl.org, jgarzik@pobox.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57320
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932527AbWI1WWf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 18:22:35 -0400
To: mchan@broadcom.com
In-Reply-To: <1159481020.3741.16.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 28 Sep 2006 15:03:40 -0700

> On Thu, 2006-09-28 at 14:53 -0700, David Miller wrote:
> 
> > I've applied Stephen's patch with PHYS_ID removed from the
> > allowed list, thanks for the feedback.
> 
> Can you remove GREGS as well?  Allowing users to dump all the registers
> will be very problematic.

I did, see my subsequent email.
