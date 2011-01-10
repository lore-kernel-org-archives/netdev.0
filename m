From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] netdev: bfin_mac: disable hardware checksum if
 writeback cache is enabled
Date: Mon, 10 Jan 2011 13:31:49 -0800 (PST)
Message-ID: <20110110.133149.63033036.davem@davemloft.net>
References: <1294664073-1950-1-git-send-email-vapier@gentoo.org>
	<1294664073-1950-5-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	sonic.zhang@analog.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37334
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754935Ab1AJVbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 16:31:17 -0500
In-Reply-To: <1294664073-1950-5-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Mon, 10 Jan 2011 07:54:33 -0500

> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> With writeback caches, corrupted RX packets will be sent up the stack
> without any error markings.
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied.
