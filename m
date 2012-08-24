From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/3] team: couple of fixes
Date: Fri, 24 Aug 2012 13:47:05 -0400 (EDT)
Message-ID: <20120824.134705.178022240623528140.davem@davemloft.net>
References: <1345728413-10298-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758637Ab2HXRrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 13:47:08 -0400
In-Reply-To: <1345728413-10298-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 23 Aug 2012 15:26:50 +0200

> + vlan helper
> 
> Jiri Pirko (3):
>   teamd: don't print warn message on -ESRCH during event send
>   vlan: add helper which can be called to se it device is used by vlan
>   team: do not allow to add VLAN challenged port when vlan is used

Applied with typos corrected :-)
