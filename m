From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] openvswitch:: link upper device for port
 devices
Date: Tue, 30 Jul 2013 00:07:09 -0700 (PDT)
Message-ID: <20130730.000709.1445016739803018253.davem@davemloft.net>
References: <1374840114-5622-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com, dev@openvswitch.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194Ab3G3HHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 03:07:10 -0400
In-Reply-To: <1374840114-5622-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 26 Jul 2013 14:01:54 +0200

> Link upper device properly. That will make IFLA_MASTER filled up.
> Set the master to port 0 of the datapath under which the port belongs.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Jesse you got this?
