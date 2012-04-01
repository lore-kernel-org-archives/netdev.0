From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Fix non TBI PHY access; a bad merge undid bug fix
 in a previous commit.
Date: Sun, 01 Apr 2012 16:16:33 -0400 (EDT)
Message-ID: <20120401.161633.43334673831055351.davem@davemloft.net>
References: <1332921954-11695-1-git-send-email-kenth.eriksson@transmode.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kenth.eriksson@transmode.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414Ab2DAUQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 16:16:38 -0400
In-Reply-To: <1332921954-11695-1-git-send-email-kenth.eriksson@transmode.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kenth Eriksson <kenth.eriksson@transmode.com>
Date: Wed, 28 Mar 2012 10:05:54 +0200

> Commit b26e478f undid bug fix in commit c3e072f8, with the result
> that non TBI (e.g. MDIO) PHYs cannot be accessed.
> 
> Signed-off-by: Kenth Eriksson <kenth.eriksson@transmode.com>

Applied and queued up for -stable.
