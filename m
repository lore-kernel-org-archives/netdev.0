From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ieee802154: Fix possible NULL pointer dereference in
 wpan_phy_alloc
Date: Sun, 23 May 2010 23:12:05 -0700 (PDT)
Message-ID: <20100523.231205.258898043.davem@davemloft.net>
References: <20100523154545.GA22578@hera.kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov@gmail.com, netdev@vger.kernel.org
To: dkirjanov@hera.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51813
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753069Ab0EXGLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:11:55 -0400
In-Reply-To: <20100523154545.GA22578@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Date: Sun, 23 May 2010 15:45:45 +0000

> Check for NULL pointer after kzalloc
> 
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>

Applied.
