From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 15:03:40 -0700
Message-ID: <1159481020.3741.16.camel@rh4>
References: <20060928122514.112a19a8@dxpl.pdx.osdl.net>
 <451C28E9.6040708@intel.com>
 <20060928.145345.90823467.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, shemminger@osdl.org, jgarzik@pobox.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:57865 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1161325AbWI1WHO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 18:07:14 -0400
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060928.145345.90823467.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-28 at 14:53 -0700, David Miller wrote:

> I've applied Stephen's patch with PHYS_ID removed from the
> allowed list, thanks for the feedback.

Can you remove GREGS as well?  Allowing users to dump all the registers
will be very problematic.

