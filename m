From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] unexport sock_enable_timestamp
Date: Fri, 26 Oct 2007 03:59:54 -0700 (PDT)
Message-ID: <20071026.035954.129761865.davem@davemloft.net>
References: <20071024162405.GC30533@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56680
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751401AbXJZK7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 06:59:54 -0400
In-Reply-To: <20071024162405.GC30533@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Wed, 24 Oct 2007 18:24:05 +0200

> sock_enable_timestamp() no longer has any modular users.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied.
