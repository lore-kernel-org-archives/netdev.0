From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: change proto destroy method to return void
Date: Sat, 14 Jun 2008 17:13:59 -0700 (PDT)
Message-ID: <20080614.171359.212671828.davem@davemloft.net>
References: <48532517.3070205@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36789
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755694AbYFOAN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 20:13:59 -0400
In-Reply-To: <48532517.3070205@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Fri, 13 Jun 2008 21:55:35 -0400

> Change struct proto destroy function pointer to return void.  Noticed by 
> Al Viro.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Looks good, applied and pushed out to net-next-2.6, thanks Brian!

