From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] rocker: move ageing_time from struct rocker
 to struct ofdpa
Date: Sat, 12 Mar 2016 20:11:27 -0500 (EST)
Message-ID: <20160312.201127.1260500577412326931.davem@davemloft.net>
References: <1457780607-21264-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56077 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753401AbcCMBLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 20:11:32 -0500
In-Reply-To: <1457780607-21264-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat, 12 Mar 2016 12:03:27 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> This is OF-DPA specific, used only there, similar to
> ofdpa_port->ageing_time. So move it to OF-DPA code.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
