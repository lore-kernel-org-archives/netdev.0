From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/14][pull request] Intel Wired LAN Driver Updates
 2013.01.27
Date: Sun, 27 Jan 2013 19:07:48 -0500 (EST)
Message-ID: <20130127.190748.404517979856325333.davem@davemloft.net>
References: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754649Ab3A1AHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 19:07:49 -0500
In-Reply-To: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sun, 27 Jan 2013 02:39:39 -0800

> This series contains updates to e1000e only.  All the updates come
> from Bruce Allan and most of the patch fix or enable features on
> i217/i218.  Most notably is patch 03 "e1000e: add support for IEEE-1588
> PTP", which is v2 of the patch based on feedback from Stephen Hemminger.
> 
> Also patch 04 "e1000e: enable ECC on I217/I218 to catch packet buffer
> memory errors" should be queued up for stable (as well as net) trees, but
> the patch does not apply cleanly to either of those trees currently.
> So I will work with Bruce to provide a version of the patch which will
> apply cleanly to net (and stable) and we can queue it up at that point
> for stable 3.5 tree.
> 
> The remaining patches are general cleanups of the code.

Thanks, please provide more commentary like this in future
pull requests, it helps me a lot and it does get added to the
merge commit I make when I pull from your tree.

> 
> The following are changes since commit 031554eab078705edb96e9a39665597e3fd22781:
>   Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks Jeff.
