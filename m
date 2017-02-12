From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6 0/7] Refactor macvtap to re-use tap functionality by
 other virtual intefaces
Date: Sat, 11 Feb 2017 21:00:20 -0500 (EST)
Message-ID: <20170211.210020.1702909319217444459.davem@davemloft.net>
References: <1486771432-15085-1-git-send-email-sainath.grandhi@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org
To: sainath.grandhi@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44238 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751076AbdBLCA1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 21:00:27 -0500
In-Reply-To: <1486771432-15085-1-git-send-email-sainath.grandhi@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sainath Grandhi <sainath.grandhi@intel.com>
Date: Fri, 10 Feb 2017 16:03:45 -0800

> Tap character devices can be implemented on other virtual interfaces like
> ipvlan, similar to macvtap. Source code for tap functionality in macvtap
> can be re-used for this purpose.
> 
> This patch series splits macvtap source into two modules, macvtap and tap.
> This patch series also includes a patch for implementing tap character
> device driver based on the IP-VLAN network interface, called ipvtap.
> 
> These patches are tested on x86 platform.

Series applied, thanks.
