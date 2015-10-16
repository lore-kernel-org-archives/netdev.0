From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/16] mlxsw: Driver update, add initial
 support for Spectrum ASIC
Date: Fri, 16 Oct 2015 07:18:27 -0700 (PDT)
Message-ID: <20151016.071827.627850069835843564.davem@davemloft.net>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228AbbJPOCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 10:02:23 -0400
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 16 Oct 2015 14:01:21 +0200

> Purpose of this patchset is to introduce initial support for Mellanox
> Spectrum ASIC, including L2 bridge forwarding offload.
> 
> The only non-mlxsw patch in this patchset is the first one, introducing
> pre-change upper notifier. That is used in last patch to ensure ports of
> single ASIC are not bridged into multiple bridges, as that scenario is
> currently not supported by driver.

This looks fine, series applied, thanks!
