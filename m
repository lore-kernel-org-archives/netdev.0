From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] netdevice: provide common routine for macvlan and vlan operstate management
Date: Thu, 3 Dec 2009 21:34:32 +0000
Message-ID: <200912032134.32338.arnd@arndb.de>
References: <4B105311.1020005@trash.net> <20091203201824.15789.7578.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: Patrick Mullaney <pmullaney@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:59488 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbZLCVe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:34:29 -0500
In-Reply-To: <20091203201824.15789.7578.stgit@mimic.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 03 December 2009 20:21:54 Patrick Mullaney wrote:
> Provide common routine for the transition of operational state for a leaf
> device during a root device transition.
> 
> Signed-off-by: Patrick Mullaney <pmullaney@novell.com>

Acked-by: Arnd Bergmann <arnd@arndb.de>

The last time this was posted, we also had an "Acked-by: Patrick McHardy
<kaber@trash.net>", which should be in there as well.

	Arnd <><
