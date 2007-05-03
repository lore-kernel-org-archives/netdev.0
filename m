From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] [AFS]: Replace rtnetlink client by direct dev_base
 walking
Date: Thu, 03 May 2007 03:28:58 -0700 (PDT)
Message-ID: <20070503.032858.43414640.davem@davemloft.net>
References: <20070503095315.26912.24270.stgit@warthog.cambridge.redhat.com>
	<20070503095331.26912.18484.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45943
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161800AbXECK25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 06:28:57 -0400
In-Reply-To: <20070503095331.26912.18484.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 03 May 2007 10:53:31 +0100

> Replace the large and complicated rtnetlink client by two simple
> functions for getting the MAC address for the first ethernet device
> and building a list of IPv4 addresses.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
