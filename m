From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: fix vfs enumeration
Date: Thu, 27 Sep 2012 18:14:26 -0400 (EDT)
Message-ID: <20120927.181426.2201976430519806547.davem@davemloft.net>
References: <1348577442-7720-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	ajit.khaparde@emulex.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754476Ab2I0WO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 18:14:27 -0400
In-Reply-To: <1348577442-7720-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Tue, 25 Sep 2012 14:50:42 +0200

> Current VFs enumeration algorithm used in be_find_vfs does not take domain
> number into the match. The match found in igb/ixgbe is more elegant and
> safe.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks Ivan.
