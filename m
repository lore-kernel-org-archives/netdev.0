From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/2] net: couple of facelifts around ethtool
 speed and duplex values
Date: Fri, 06 Jun 2014 16:24:20 -0700 (PDT)
Message-ID: <20140606.162420.854669528512078928.davem@davemloft.net>
References: <1402057021-12867-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752364AbaFFXY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 19:24:26 -0400
In-Reply-To: <1402057021-12867-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  6 Jun 2014 14:16:59 +0200

> Jiri Pirko (2):
>   net: use SPEED_UNKNOWN and DUPLEX_UNKNOWN when appropriate
>   net: use ethtool_cmd_speed_set helper to set ethtool speed value

Series applied to net-next, thanks Jiri.
