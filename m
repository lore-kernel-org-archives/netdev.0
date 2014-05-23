From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/10][pull request] Intel Wired LAN Driver
 Updates
Date: Fri, 23 May 2014 16:14:06 -0400 (EDT)
Message-ID: <20140523.161406.261965778686662668.davem@davemloft.net>
References: <1400849956-8387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55386 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbaEWUOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 16:14:08 -0400
In-Reply-To: <1400849956-8387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 23 May 2014 05:59:06 -0700

> This series contains updates to igb, igbvf, ixgbe, i40e and i40evf.
> 
> Jacob provides eight patches to cleanup the ixgbe driver to resolve various
> checkpatch.pl warnings/errors as well as minor coding style issues.
> 
> Stephen Hemminger and I provide simple cleanups of void functions which
> had useless return statements at the end of the function which are not
> needed.
> 
> v2: Dropped Emil's patch "ixgbe: fix the detection of SFP+ capable interfaces"
>     while I wait for his updated patch to be validated.

Pulled, thanks a lot Jeff.
