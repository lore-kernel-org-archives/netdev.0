From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9] netdev: bfin_mac: use promiscuous flag for
 promiscuous mode
Date: Mon, 17 May 2010 17:22:01 -0700 (PDT)
Message-ID: <20100517.172201.102546225.davem@davemloft.net>
References: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
	<1273505954-32588-7-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	sonic.zhang@analog.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43056
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755864Ab0ERAVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 20:21:52 -0400
In-Reply-To: <1273505954-32588-7-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Mon, 10 May 2010 11:39:12 -0400

> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> Rather than using the Receive All Frames (RAF) bit to enable promiscuous
> mode, use the Promiscuous (PR) bit.  This lowers overhead at runtime as
> we let the hardware process the packets that should actually be checked.
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied.
