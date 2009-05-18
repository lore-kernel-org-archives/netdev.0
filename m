From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2.6.30] WiMAX pull request
Date: Sun, 17 May 2009 21:14:54 -0700 (PDT)
Message-ID: <20090517.211454.57013574.davem@davemloft.net>
References: <cover.1242405228.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org
To: inaky@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36504
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755776AbZEREO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 00:14:56 -0400
In-Reply-To: <cover.1242405228.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Fri, 15 May 2009 12:07:32 -0700

> This patch fixes a device crash due to a bad optimization. It won't
> crash the system, but just render the WiMAX device unusable on bad
> radio link conditions. 
> 
> The following changes since commit e1cc1c578055d20d36e084e324001fb5e0355a71:
>   David S. Miller (1):
>         Merge branch 'net-fixes' of git://git.kernel.org/.../chris/linux-2.6
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git linux-2.6.30.y
> 
> Patches follow for reviewing convenience.

Pulled, thanks!
