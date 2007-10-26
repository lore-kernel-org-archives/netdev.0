From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make ircomm_tty static
Date: Fri, 26 Oct 2007 03:56:52 -0700 (PDT)
Message-ID: <20071026.035652.189993268.davem@davemloft.net>
References: <20071024162355.GZ30533@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ryanr23@gmail.com, samuel@sortiz.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39699
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751554AbXJZK4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 06:56:50 -0400
In-Reply-To: <20071024162355.GZ30533@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Wed, 24 Oct 2007 18:23:55 +0200

> ircomm_tty can now become static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied.
