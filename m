From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] unexport inet_listen_wlock
Date: Wed, 13 Feb 2008 17:40:36 -0800 (PST)
Message-ID: <20080213.174036.30349691.davem@davemloft.net>
References: <20080213212948.GL3383@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59793
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764255AbYBNBkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 20:40:05 -0500
In-Reply-To: <20080213212948.GL3383@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Wed, 13 Feb 2008 23:29:48 +0200

> This patch removes the no linger used EXPORT_SYMBOL(inet_listen_wlock).
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied.
