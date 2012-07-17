From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/2][pull request] Intel Wired LAN Driver Updates
Date: Mon, 16 Jul 2012 23:20:01 -0700 (PDT)
Message-ID: <20120716.232001.2141239607001273760.davem@davemloft.net>
References: <1342252063-27023-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787Ab2GQGUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 02:20:02 -0400
In-Reply-To: <1342252063-27023-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 14 Jul 2012 00:47:41 -0700

> This series contains fixes to e1000e.
> 
> The following are changes since commit 7ac2908e4b2edaec60e9090ddb4d9ceb76c05e7d:
>   sch_sfb: Fix missing NULL check
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master
> 
> Bruce Allan (1):
>   e1000e: fix test for PHY being accessible on 82577/8/9 and I217
> 
> Tushar Dave (1):
>   e1000e: Correct link check logic for 82571 serdes

Pulled, thanks Jeff.
