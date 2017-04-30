From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/4][pull request] 1GbE Intel Wired LAN Driver
 Updates 2017-04-30
Date: Sun, 30 Apr 2017 11:35:52 -0400 (EDT)
Message-ID: <20170430.113552.1370074918240589323.davem@davemloft.net>
References: <20170430123614.67897-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49814 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033374AbdD3Pfy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 11:35:54 -0400
In-Reply-To: <20170430123614.67897-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sun, 30 Apr 2017 05:36:10 -0700

> This series contains updates to e1000e only.
> 
> Jarod Wilson fixes an issue where the workaround for 82574 & 82583
> is needed for i218 as well, so set the appropriate flags.
> 
> Sasha adds support for the upcoming new i219 devices for the client
> platform (CannonLake), which includes the support for 38.4MHz frequency
> to support PTP on CannonLake.
> 
> The following are changes since commit c08bac03d2894113bdb114e66e6ada009defb120:
>   Merge branch '10GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Pulled.
