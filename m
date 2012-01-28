From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/11][pull request] Intel Wired LAN Driver Updates
Date: Fri, 27 Jan 2012 20:47:38 -0500 (EST)
Message-ID: <20120127.204738.106644994514187241.davem@davemloft.net>
References: <1327633729-14086-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47553 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697Ab2A1Brp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 20:47:45 -0500
In-Reply-To: <1327633729-14086-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 26 Jan 2012 19:08:38 -0800

> The following series contains updates to e1000e only.  This is the
> second batch of e1000e patches and these changes contain
> fixups/cleanups/conversions.  Most notably is the split up of lib.c
> into mac.c, manage.c and nvm.c.
> 
> The following are changes since commit a7563f342db6490e66dbf2c8a50577a72a158c9a:
>   ipv6: Use ipv6_addr_any()
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks Jeff.
