From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Wed, 04 Sep 2013 12:41:14 -0400 (EDT)
Message-ID: <20130904.124114.1635489897510235764.davem@davemloft.net>
References: <1378300136-26003-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935245Ab3IDQlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 12:41:16 -0400
In-Reply-To: <1378300136-26003-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  4 Sep 2013 06:08:47 -0700

> This series contains updates to igb only.
> 
> Todd provides a fix for igb to not look for a PBA in the iNVM on
> devices that are flashless.
> 
> Akeem provides igb patches to add a new PHY id for i354, as well as
> a couple of patches to implement the new PHY id.  He also provides
> several patches to correctly report the appropriate media type as
> well as correctly report advertised/supported link for i354 devices.
> Lastly Akeem implements a 1 second delay mechanism for i210 devices
> to avoid erroneous link issue with the link partner.

Pulled, thanks a lot Jeff.
