From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] smsc75xx: more minor fixes
Date: Mon, 07 May 2012 23:44:46 -0400 (EDT)
Message-ID: <20120507.234446.722270343364945890.davem@davemloft.net>
References: <1336129033-15826-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757751Ab2EHDot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 23:44:49 -0400
In-Reply-To: <1336129033-15826-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Fri,  4 May 2012 11:57:10 +0100

> 3 more minor patches for smsc75xx
> 
> Steve Glendinning (3):
>   smsc75xx: replace 0xffff with PHY_INT_SRC_CLEAR_ALL
>   smsc75xx: eliminate unnecessary phy register read
>   smsc75xx: let EEPROM determine GPIO/LED settings

All applied to net-next.  Please be specific in the future about where
you want patches applied, these wouldn't apply cleanly until I merged
'net' into 'net-next' to propagate recent bug fixes first.
