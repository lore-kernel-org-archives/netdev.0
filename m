From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] netdev: bfin_mac: mark setup_system_regs as static
Date: Mon, 10 Jan 2011 13:31:36 -0800 (PST)
Message-ID: <20110110.133136.90801526.davem@davemloft.net>
References: <1294664073-1950-1-git-send-email-vapier@gentoo.org>
	<1294664073-1950-2-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37318
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754913Ab1AJVbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 16:31:03 -0500
In-Reply-To: <1294664073-1950-2-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Mon, 10 Jan 2011 07:54:30 -0500

> No need for this to be exported since it is only used in this driver.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied.
