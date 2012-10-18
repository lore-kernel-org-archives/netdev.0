From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] vlan: allow to change type when no vlan device is
 hooked on netdev
Date: Thu, 18 Oct 2012 15:35:39 -0400 (EDT)
Message-ID: <20121018.153539.1540285041603430362.davem@davemloft.net>
References: <1350473856-29380-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	kaber@trash.net, jstanley@rmrf.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248Ab2JRTfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 15:35:42 -0400
In-Reply-To: <1350473856-29380-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 17 Oct 2012 13:37:36 +0200

> vlan_info might be present but still no vlan devices might be there.
> That is in case of vlan0 automatically added.
> 
> So in that case, allow to change netdev type.
> 
> Reported-by: Jon Stanley <jstanley@rmrf.net>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied and queued up for -stable, thanks.
