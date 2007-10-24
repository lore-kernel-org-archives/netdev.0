From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Cleanup the IPv6 addresses printing in /proc files
Date: Tue, 23 Oct 2007 21:15:36 -0700
Message-ID: <1193199336.11845.53.camel@localhost>
References: <471E2342.8090907@openvz.org>
	 <20071023.204350.59654390.davem@davemloft.net>
	 <1193198641.11845.49.camel@localhost>
	 <20071023.211045.23014439.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3153 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752118AbXJXEPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2007 00:15:49 -0400
In-Reply-To: <20071023.211045.23014439.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-10-23 at 21:10 -0700, David Miller wrote:
> We'll break things if we change it.

Maybe, but definitely the macro names should
reflect this brokenness.

