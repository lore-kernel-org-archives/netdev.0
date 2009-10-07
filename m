From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] Incomplete type for struct in6_addr
Date: Wed, 07 Oct 2009 14:42:03 -0700 (PDT)
Message-ID: <20091007.144203.218248331.davem@davemloft.net>
References: <1254951282-5056-1-git-send-email-hagen@jauu.net>
	<1254951282-5056-3-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48576
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753192AbZJGVmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 17:42:08 -0400
In-Reply-To: <1254951282-5056-3-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Wed,  7 Oct 2009 23:34:41 +0200

> if_tunnel.h defines a new struct consisting of struct in6_addr,
> but the definition is defined in linux/in6.h - so we must
> include them beforehand.
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

Already fixed in net-next-2.6
