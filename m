From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] result of csum_fold() is already 16bit, no need to cast
Date: Sat, 26 Apr 2008 22:29:06 -0700 (PDT)
Message-ID: <20080426.222906.193695192.davem@davemloft.net>
References: <20080427052730.GQ5882@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55413
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751246AbYD0F3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 01:29:06 -0400
In-Reply-To: <20080427052730.GQ5882@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sun, 27 Apr 2008 06:27:30 +0100

> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Applied, thanks Al.
