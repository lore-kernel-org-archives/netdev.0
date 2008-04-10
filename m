From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] [IPV6] Remove three method declarations in
 include/net/ndisc.h.
Date: Thu, 10 Apr 2008 02:01:31 -0700 (PDT)
Message-ID: <20080410.020131.264375762.davem@davemloft.net>
References: <eb3ff54b0804010433v67f0ea60w4681b3a3400c3484@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45080
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752480AbYDJJBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 05:01:30 -0400
In-Reply-To: <eb3ff54b0804010433v67f0ea60w4681b3a3400c3484@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Tue, 1 Apr 2008 14:33:54 +0300

> Hi,
> This patch removes two unused method declarations in include/net/ndisc.h:
> ndisc_forwarding_on(void) and  ndisc_forwarding_off(void);
> Also igmp6_cleanup(void) appears twice in this header, so one
> igmp6_cleanup(void)
> declaration is removed.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied to net-2.6.26, thanks.
