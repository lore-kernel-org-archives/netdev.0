From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [AX25]: Kill ax25_bind() user triggable printk.
Date: Mon, 28 Jan 2008 20:44:24 -0800 (PST)
Message-ID: <20080128.204424.14853110.davem@davemloft.net>
References: <1201541470-25312-1-git-send-email-max@stro.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: max@stro.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41778
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755959AbYA2EoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 23:44:07 -0500
In-Reply-To: <1201541470-25312-1-git-send-email-max@stro.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: maximilian attems <max@stro.at>
Date: Mon, 28 Jan 2008 18:31:09 +0100

> on the last run overlooked that sfuzz triggable message.
> move the message to the corresponding comment.
> 
> Signed-off-by: maximilian attems <max@stro.at>

Applied.
