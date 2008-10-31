From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] net: replace NIPQUAD() in net/*/
Date: Fri, 31 Oct 2008 00:55:21 -0700 (PDT)
Message-ID: <20081031.005521.101911698.davem@davemloft.net>
References: <1225412026.5574.35.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38806
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753357AbYJaHzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 03:55:46 -0400
In-Reply-To: <1225412026.5574.35.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Thu, 30 Oct 2008 17:13:46 -0700

> Using NIPQUAD() with NIPQUAD_FMT, %d.%d.%d.%d or %u.%u.%u.%u
> can be replaced with %pI4
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied.
