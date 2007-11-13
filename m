From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] unexport sysctl_{r,w}mem_max
Date: Mon, 12 Nov 2007 21:24:27 -0800 (PST)
Message-ID: <20071112.212427.09929763.davem@davemloft.net>
References: <20071111064837.GI21669@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33413
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751956AbXKMFY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:24:27 -0500
In-Reply-To: <20071111064837.GI21669@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Sun, 11 Nov 2007 07:48:37 +0100

> sysctl_{r,w}mem_max can now be unexported.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied, thanks Adrian.
