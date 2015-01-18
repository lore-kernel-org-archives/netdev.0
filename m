From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/2] switchdev: introduce switchdev notifier
Date: Sun, 18 Jan 2015 00:24:13 -0500 (EST)
Message-ID: <20150118.002413.2112214810523387929.davem@davemloft.net>
References: <1421362177-10719-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, sfeldma@gmail.co,
	stephen@networkplumber.org, linus.luessing@web.de, tgraf@suug.ch
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbbARFYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 00:24:16 -0500
In-Reply-To: <1421362177-10719-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 15 Jan 2015 23:49:36 +0100

> This patch introduces new notifier for purposes of exposing events which happen
> on switch driver side. The consumers of the event messages are mainly involved
> masters, namely bridge and ovs.
> 
> Suggested-by: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
