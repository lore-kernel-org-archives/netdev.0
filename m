From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/3] i40e: fix un-necessary Tx hangs
Date: Tue, 06 Jan 2015 13:31:21 -0500 (EST)
Message-ID: <20150106.133121.1847060351473231478.davem@davemloft.net>
References: <1420533864-13125-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1420533864-13125-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<20150106090440.00006a7d@unknown>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755996AbbAFSbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 13:31:23 -0500
In-Reply-To: <20150106090440.00006a7d@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Tue, 6 Jan 2015 09:04:40 -0800

> Dave, sorry to do this but we discovered a bug in this patch (where
> this patch impacts performance) and didn't interrupt Jeff before he sent
> it (my mistake) I will prep a v2 for Jeff.
> 
> Please do not apply.

Ok.
