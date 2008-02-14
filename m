From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] unexport __inet_hash_connect
Date: Wed, 13 Feb 2008 17:39:44 -0800 (PST)
Message-ID: <20080213.173944.256911535.davem@davemloft.net>
References: <20080213212946.GK3383@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59790
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761211AbYBNBjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 20:39:13 -0500
In-Reply-To: <20080213212946.GK3383@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Wed, 13 Feb 2008 23:29:46 +0200

> This patch removes the unused EXPORT_SYMBOL_GPL(__inet_hash_connect).
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied.
