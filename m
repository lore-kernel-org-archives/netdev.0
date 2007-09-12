From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/3] sk98lin: restore driver
Date: Wed, 12 Sep 2007 14:05:19 +0200
Message-ID: <20070912140519.39cad155@oldman>
References: <6278d2220707271227g51cb147ch2f6dbc05c73f618d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60508 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1765256AbXILMFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:05:09 -0400
In-Reply-To: <6278d2220707271227g51cb147ch2f6dbc05c73f618d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit e1abecc48938fbe1966ea6e78267fc673fa59295.

The driver works on some hardware that skge doesn't handle yet.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

-----------
Patch too large for mailing list. Download from:
	http://developer.osdl.org/shemminger/patches/sk98lin-2.6.23-restore.patch
