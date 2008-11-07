From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phonet: sparse annotations of protocol, remove forward
 declaration
Date: Thu, 06 Nov 2008 23:11:01 -0800 (PST)
Message-ID: <20081106.231101.22551102.davem@davemloft.net>
References: <1226022793.5482.1.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: remi.denis-courmont@nokia.com, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53745
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751189AbYKGHLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 02:11:02 -0500
In-Reply-To: <1226022793.5482.1.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Thu, 06 Nov 2008 17:53:13 -0800

> net/phonet/af_phonet.c:38:36: error: marked inline, but without a definition
> net/phonet/pep-gprs.c:63:10: warning: incorrect type in return expression (different base types)
> net/phonet/pep-gprs.c:63:10:    expected int
> net/phonet/pep-gprs.c:63:10:    got restricted __be16 [usertype] <noident>
> net/phonet/pep-gprs.c:65:10: warning: incorrect type in return expression (different base types)
> net/phonet/pep-gprs.c:65:10:    expected int
> net/phonet/pep-gprs.c:65:10:    got restricted __be16 [usertype] <noident>
> net/phonet/pep-gprs.c:124:16: warning: incorrect type in assignment (different base types)
> net/phonet/pep-gprs.c:124:16:    expected restricted __be16 [usertype] protocol
> net/phonet/pep-gprs.c:124:16:    got unsigned short [unsigned] [usertype] protocol
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Looks good, applied to net-next-2.6

Thanks.
