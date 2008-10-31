From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] misc: replace NIPQUAD()
Date: Fri, 31 Oct 2008 00:56:56 -0700 (PDT)
Message-ID: <20081031.005656.240209788.davem@davemloft.net>
References: <1225412028.5574.38.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32960
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752617AbYJaH5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 03:57:21 -0400
In-Reply-To: <1225412028.5574.38.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Thu, 30 Oct 2008 17:13:48 -0700

> Using NIPQUAD() with NIPQUAD_FMT, %d.%d.%d.%d or %u.%u.%u.%u
> can be replaced with %pI4
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied.
