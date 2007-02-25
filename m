From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix limited slow start bug
Date: Sun, 25 Feb 2007 15:43:11 -0800 (PST)
Message-ID: <20070225.154311.71091747.davem@davemloft.net>
References: <6.1.1.1.2.20070225095105.049cd960@192.168.6.12>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: simrw@sim-basis.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52453
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752437AbXBYXqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Feb 2007 18:46:22 -0500
In-Reply-To: <6.1.1.1.2.20070225095105.049cd960@192.168.6.12>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roger While <simrw@sim-basis.de>
Date: Sun, 25 Feb 2007 09:55:34 +0100

> Was anything done about size/member alignment of struct tcp_sock per
> mail from last year  -
> http://marc.theaimsgroup.com/?l=linux-netdev&m=114318857102290&w=2
> 
> (I have no idea what current size is)

Nothing has been done yet but I've been thinking about it a lot
over the past year and I've had some discussions with other
developers such as Arnaldo.

It's just a matter of me being backlogged, so I never get to
it as often as I would like :)
