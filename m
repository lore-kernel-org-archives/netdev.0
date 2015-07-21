From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rocker: forward packets to CPU when port is
 joined to openvswitch
Date: Mon, 20 Jul 2015 18:26:49 -0700 (PDT)
Message-ID: <20150720.182649.818342477366209714.davem@davemloft.net>
References: <1437010754-29038-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757128AbbGUB0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 21:26:53 -0400
In-Reply-To: <1437010754-29038-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Thu, 16 Jul 2015 10:39:14 +0900

> Teach rocker to forward packets to CPU when a port is joined to Open vSwitch.
> There is scope to later refine what is passed up as per Open vSwitch flows
> on a port.
> 
> This does not change the behaviour of rocker ports that are
> not joined to Open vSwitch.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied, thanks Simon.
