From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: raw sockets rewriting IP ID in rare cases.
Date: Sun, 15 Aug 2010 13:13:59 -0700 (PDT)
Message-ID: <20100815.131359.191392588.davem@davemloft.net>
References: <201008131307.38381.morgon.j.kanter@dartmouth.edu>
	<20100814.223532.242143460.davem@davemloft.net>
	<20100815135741.1iud2jvgw0wwg4kw@webmail.dartmouth.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Morgon.J.Kanter@Dartmouth.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33723
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751386Ab0HOUNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Aug 2010 16:13:42 -0400
In-Reply-To: <20100815135741.1iud2jvgw0wwg4kw@webmail.dartmouth.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Morgon.J.Kanter@Dartmouth.edu
Date: Sun, 15 Aug 2010 13:57:41 -0400

> Is there a way to turn this behavior off, then, with raw sockets? Zero
> is the desired ID value.

No, there isn't.
