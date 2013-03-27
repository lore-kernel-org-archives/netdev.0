From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Wed, 27 Mar 2013 14:10:05 -0400 (EDT)
Message-ID: <20130327.141005.2019226838588462523.davem@davemloft.net>
References: <1364382333-14721-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58892 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905Ab3C0SKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 14:10:09 -0400
In-Reply-To: <1364382333-14721-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 27 Mar 2013 04:05:30 -0700

> This series contains updates to e1000, ixgb and e1000e for Christoph.
> 
> Christoph provides 3 patches to resolve missing dma_error_call's to
> provided Intel drivers which did not have this fix.

Pulled, thanks Jeff.
