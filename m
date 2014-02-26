From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 6/6] doc: update SubmittingPatches about the Fixed
 tag
Date: Wed, 26 Feb 2014 15:54:20 -0500 (EST)
Message-ID: <20140226.155420.1946480320179853521.davem@davemloft.net>
References: <1393379938-1415-1-git-send-email-aaron.f.brown@intel.com>
	<1393379938-1415-7-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacob.e.keller@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbaBZUyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 15:54:22 -0500
In-Reply-To: <1393379938-1415-7-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Brown <aaron.f.brown@intel.com>
Date: Tue, 25 Feb 2014 17:58:58 -0800

> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> This patch updates the SubmittingPatches process to include howto about
> the new 'Fixed' tag to be used when a patch fixes an issue in a previous
> commit (found by git-bisect for example).
> 
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>

It is not appropriate to submit this via the networking tree, you should
submit this via LKML instead.

I'm going to apply this series minus this patch, thanks.
