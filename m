From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4 net-next] tg3: Improve PCI function number
 detection.
Date: Sun, 06 Jan 2013 21:02:56 -0800 (PST)
Message-ID: <20130106.210256.85325634010682237.davem@davemloft.net>
References: <1357512670-17636-1-git-send-email-mchan@broadcom.com>
	<1357512670-17636-2-git-send-email-mchan@broadcom.com>
	<1357512670-17636-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38037 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018Ab3AGFC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 00:02:56 -0500
In-Reply-To: <1357512670-17636-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 6 Jan 2013 14:51:09 -0800

> Simplify the code to detect PCI function number on 5717, 5719, and 5720.
> If shared memory does not have proper signature, read the function number
> from register directly.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
