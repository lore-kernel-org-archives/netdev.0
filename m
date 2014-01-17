From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/3] i40e: check desc pointer before printing
Date: Thu, 16 Jan 2014 17:21:08 -0800 (PST)
Message-ID: <20140116.172108.577846253258379840.davem@davemloft.net>
References: <1389827904-14713-1-git-send-email-aaron.f.brown@intel.com>
	<1389827904-14713-3-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shannon.nelson@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55790 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbaAQBVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 20:21:09 -0500
In-Reply-To: <1389827904-14713-3-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Brown <aaron.f.brown@intel.com>
Date: Wed, 15 Jan 2014 15:18:23 -0800

> From: Shannon Nelson <shannon.nelson@intel.com>
> 
> Check that the descriptors were allocated before trying to dump
> them to the logfile.  While we're there, de-trick-ify the code
> so as to be easier to read and not abusing the types and unions.
> 
> Change-ID: I22898f4b22cecda3582d4d9e4018da9cd540f177
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>

Applied.
