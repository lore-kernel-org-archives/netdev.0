From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 01/42] appletalk: convert aarp to net_device_ops
Date: Wed, 07 Jan 2009 19:09:32 -0800
Message-ID: <1231384172.1739.31.camel@localhost>
References: <20090107003316.784424362@vyatta.com>
	 <20090107003345.513599743@vyatta.com>
	 <20090107.172155.115059815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, acme@ghostprotcols.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3127 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbZAHDIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 22:08:42 -0500
In-Reply-To: <20090107.172155.115059815.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-07 at 17:21 -0800, David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Applied.

Was it necessary to preface ndo_ to all the netdev_ops members?
It's a bit hungarian compared to most all kernel sources.

