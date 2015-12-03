From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: core: Change BUG to WARN in hwmon code
Date: Thu, 03 Dec 2015 15:27:00 -0500 (EST)
Message-ID: <20151203.152700.1265522811814410731.davem@davemloft.net>
References: <1449133923-3021-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, gerlitz.or@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844AbbLCU1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 15:27:02 -0500
In-Reply-To: <1449133923-3021-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  3 Dec 2015 10:12:03 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Better to just warn the user that something really odd is going on and
> continue to run.
> 
> Suggested-by: Or Gerlitz <gerlitz.or@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
