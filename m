From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/6] switchdev: bring back switchdev_obj
Date: Sat, 03 Oct 2015 04:50:23 -0700 (PDT)
Message-ID: <20151003.045023.1505695956387654766.davem@davemloft.net>
References: <1443690226-29833-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbbJCLev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 07:34:51 -0400
In-Reply-To: <1443690226-29833-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  1 Oct 2015 11:03:40 +0200

> Second version of the patch extends to a patchset. Basically this patchset
> brings object structure back which disappeared with recent Vivien's patchset.
> Also it does a bit of naming changes in order to get the things in line.
> Also, object id is put back into object structure.
> Thanks to Scott and Vivien for review and suggestions.

Series applied, thanks Jiri.
