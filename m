From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] ipv6: ip6mr: support multiple independant
 multicast routing instances
Date: Wed, 12 May 2010 23:31:30 -0700 (PDT)
Message-ID: <20100512.233130.104075508.davem@davemloft.net>
References: <1273586551-3521-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45002
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752970Ab0EMGbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 02:31:22 -0400
In-Reply-To: <1273586551-3521-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Tue, 11 May 2010 16:02:25 +0200

> The following patches add support for multiple independant IPv6 multicast
> routing instances. This can be useful to seperate traffic when building
> a multicast router that is serving multiple independant networks.
> 
> The patchset is pretty much a straight forward port from IPv4 with no
> significant differences.
 ...
> These patches have been tested using pim6sd and mrd6.
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/ipmr-2.6.git master

Pulled, thanks!
