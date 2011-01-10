From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] netdev: bfin_mac: clean up printk messages
Date: Mon, 10 Jan 2011 13:31:31 -0800 (PST)
Message-ID: <20110110.133131.43031998.davem@davemloft.net>
References: <1294664073-1950-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37312
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754745Ab1AJVa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 16:30:59 -0500
In-Reply-To: <1294664073-1950-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Mon, 10 Jan 2011 07:54:29 -0500

> Use netdev_* and pr_* helper funcs for output rather than printk.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied.
