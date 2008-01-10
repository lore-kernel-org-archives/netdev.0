From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] AX25: kill user triggable printks
Date: Thu, 10 Jan 2008 03:58:06 -0800 (PST)
Message-ID: <20080110.035806.12098194.davem@davemloft.net>
References: <1199874070-9524-1-git-send-email-max@stro.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: max@stro.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41263
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753681AbYAJL6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 06:58:14 -0500
In-Reply-To: <1199874070-9524-1-git-send-email-max@stro.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: maximilian attems <max@stro.at>
Date: Wed,  9 Jan 2008 11:21:10 +0100

> sfuzz can easily trigger any of those.
> 
> move the printk message to the corresponding comment:
> makes the intention of the code clear and easy
> to pick up on an scheduled removal.
> as bonus simplify the braces placement.
> 
> Signed-off-by: maximilian attems <max@stro.at>

Applied, thanks.
