From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] move unneeded data to initdata section
Date: Tue, 13 Nov 2007 03:24:15 -0800 (PST)
Message-ID: <20071113.032415.57038512.davem@davemloft.net>
References: <20071107120100.GA10185@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devel@openvz.org, containers@lists.osdl.org,
	netdev@vger.kernel.org, clg@fr.ibm.com, benjamin.thery@bull.net
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55954
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751527AbXKMLYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 06:24:16 -0500
In-Reply-To: <20071107120100.GA10185@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 7 Nov 2007 15:01:00 +0300

> This patch reverts Eric's commit 2b008b0a8e96b726c603c5e1a5a7a509b5f61e35
> 
> It diets .text & .data section of the kernel if CONFIG_NET_NS is not set.
> This is safe after list operations cleanup.
> 
> Signed-of-by: Denis V. Lunev <den@openvz.org>

Applied, thanks Denis.
