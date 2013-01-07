From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4 net-next] tg3: Remove IS_ENABLED(CONFIG_HWMON) check
Date: Sun, 06 Jan 2013 21:03:02 -0800 (PST)
Message-ID: <20130106.210302.1819456224586524543.davem@davemloft.net>
References: <1357512670-17636-2-git-send-email-mchan@broadcom.com>
	<1357512670-17636-3-git-send-email-mchan@broadcom.com>
	<1357512670-17636-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38044 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036Ab3AGFDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 00:03:03 -0500
In-Reply-To: <1357512670-17636-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 6 Jan 2013 14:51:10 -0800

> From: Nithin Nayak Sujir <nsujir@broadcom.com>
> 
> Commit de0a41484c47d783dd4d442914815076aa2caac2 added Kconfig logic to
> select HWMON and removed all the IS_ENABLED(CONFIG_HWMON) checks in the
> tg3.c file. It missed this one check in the header.
> 
> Update version to 3.129 and update copyright year.
> 
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
