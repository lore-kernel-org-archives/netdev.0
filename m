From: David Miller <davem@davemloft.net>
Subject: Re: PATCH[1/1] niu: panic on reset
Date: Fri, 12 Sep 2008 16:04:38 -0700 (PDT)
Message-ID: <20080912.160438.216446871.davem@davemloft.net>
References: <48CAC9EE.1000700@Sun.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Matheos.Worku@Sun.COM, agospoda@redhat.com
To: Santwona.Behera@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48873
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756817AbYILXEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 19:04:44 -0400
In-Reply-To: <48CAC9EE.1000700@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santwona.Behera@Sun.COM
Date: Fri, 12 Sep 2008 12:58:38 -0700

> The reset_task function in the niu driver does not reset the tx and rx buffers
> properly. This leads to panic on reset. This patch is a modified implementation
> of the previously posted fix.

Patch applied, thanks for following up on this.
