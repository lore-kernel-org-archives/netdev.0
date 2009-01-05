From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] qlge: bugfix: Fix register access error checking.
Date: Sun, 04 Jan 2009 17:09:53 -0800 (PST)
Message-ID: <20090104.170953.36847815.davem@davemloft.net>
References: <20081230211122.GD16018@susedev.qlogic.org>
	<1230671545-19084-5-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com,
	bhutchings@solarflare.com, hch@infradead.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40537
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751729AbZAEBJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 20:09:49 -0500
In-Reply-To: <1230671545-19084-5-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Tue, 30 Dec 2008 13:12:25 -0800

> Some indexed registers do not have error bits. In these cases a
> value of zero should be used for error checking.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Also applied, thanks Ron.
