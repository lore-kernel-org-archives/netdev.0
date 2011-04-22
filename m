From: David Miller <davem@davemloft.net>
Subject: Re: rtnetlink and many VFs
Date: Fri, 22 Apr 2011 15:31:45 -0700 (PDT)
Message-ID: <20110422.153145.183062300.davem@davemloft.net>
References: <43F901BD926A4E43B106BF17856F07550145FC75D6@orsmsx508.amr.corp.intel.com>
	<1303409517.3165.39.camel@bwh-desktop>
	<43F901BD926A4E43B106BF17856F0755014603C6BE@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35703
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756572Ab1DVWcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 18:32:19 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F0755014603C6BE@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Date: Fri, 22 Apr 2011 15:29:41 -0700

> If someone who knew (or knows) a bit more about netlink could point
> out where this limitation is set in the code I'd really appreciate
> it.  I've been poking around for a few hours and still can't find
> it.

NLMSG_GOODSIZE
