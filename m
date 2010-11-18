From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 0/3] e1000/e1000e/igb MDI-X control implementation
Date: Thu, 18 Nov 2010 00:14:13 +0000
Message-ID: <1290039253.30433.85.camel@localhost>
References: <20101117232645.3513.20655.stgit@jbrandeb-ich9b.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:45969 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823Ab0KRAOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 19:14:16 -0500
In-Reply-To: <20101117232645.3513.20655.stgit@jbrandeb-ich9b.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-11-17 at 15:29 -0800, Jesse Brandeburg wrote:
> this patch series is RFC for implemenation, I've briefly tested
> it to make sure I still get link after setting MDI-X and I see
> the status change in ethtool.
> 
> The basic idea is to fill out the MDI-X read functionality with
> some write functionality.
> 
> the e1000e patch is actually what drove this change as some users
> have found wonky switches that must have MDI/MDI-X forced.
[...]

I object to all these for the reasons explained in my comments on the
changes to the ethtool utility.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

