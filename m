From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-caif: drop redundant Kconfig entries
Date: Sun, 23 May 2010 23:12:40 -0700 (PDT)
Message-ID: <20100523.231240.08979885.davem@davemloft.net>
References: <1274474720-9865-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sjur.brandeland@stericsson.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51824
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753095Ab0EXGMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:12:30 -0400
In-Reply-To: <1274474720-9865-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Fri, 21 May 2010 16:45:20 -0400

> There is already a submenu entry that is always displayed, so there is
> no need to also show a dedicated CAIF comment.
> 
> Drop dead commented code while we're here, and change the submenu text
> to better match the style everyone else is using.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied.
