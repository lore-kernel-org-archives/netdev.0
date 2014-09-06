From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/2][pull request] Intel Wired LAN Driver Updates
 2014-09-06
Date: Sat, 06 Sep 2014 12:30:45 -0700 (PDT)
Message-ID: <20140906.123045.2083806174391105472.davem@davemloft.net>
References: <1410006842-26517-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40505 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbaIFTaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 15:30:46 -0400
In-Reply-To: <1410006842-26517-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat,  6 Sep 2014 05:34:00 -0700

> This series contains updates to e1000 and igb.
> 
> Krzysztof provides a patch to cleanup the coding style in e1000 to quiet
> checkpatch.pl warnings.
> 
> Todd adds two boolean flags to igb to allow for changes in the
> advertised EEE speeds from ethtool.
> 
> The following are changes since commit cfecec56ae7c7c40f23fbdac04acee027ca3bd66:
>   mlx4: only pull headers into skb head
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks Jeff.
