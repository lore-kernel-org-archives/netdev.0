From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m driver v2
Date: Thu, 27 Nov 2008 01:24:53 -0800
Message-ID: <200811270124.53492.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com> <20081127.001748.204325827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:46082 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750742AbYK0JZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 04:25:24 -0500
In-Reply-To: <20081127.001748.204325827.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 November 2008, David Miller wrote:
> From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
> Date: Wed, 26 Nov 2008 14:40:19 -0800
>
> > Changes since v1:
> >
> >  - (Stephen Hemminger) don't use bitfields in struct wimax_dev
> >
> >  - (Stephen Hemminger) don't use the interface name for the generic
> >    netlink family, as it might change on if rename. Change to use the
> >    interface index.
> >
> >  - (David Miller) move the WiMAX stack to net/wimax
> >
> >  - misc checkpatch fixes, kconfig cleanups.
> >
> >  - use DEFINE_SPINLOCK
>
> I'm fine with this, so feel free to merge this stuff in via
> the USB stack (due to the dependencies there).

Thanks David -- I'll wait for some feedback some guys told me they were
going to send and submit (latest on Monday) the patchset to Greg KH.

-- 
Inaky
