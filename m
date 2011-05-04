From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 0/9][pull request] Intel Wired LAN Driver Update
Date: Wed, 04 May 2011 13:59:04 -0700 (PDT)
Message-ID: <20110504.135904.229767743.davem@davemloft.net>
References: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<20110504.135621.232749554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41502
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755999Ab1EDU7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 16:59:36 -0400
In-Reply-To: <20110504.135621.232749554.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


BTW, Jeff, can I get some kind of time frame on when the ethtool_ops->phys_id
conversions/removals for e100, e1000, and igb will be coming my way?

It's starting to be on the order of weeks that I've been waiting for
this so that I can apply Stephen Hemminger's patch which gets rid of
the old ->phys_id interfaces entirely.

Thanks.
