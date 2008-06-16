From: David Miller <davem@davemloft.net>
Subject: Re: How can i know if I/OAT is supported?
Date: Mon, 16 Jun 2008 15:00:19 -0700 (PDT)
Message-ID: <20080616.150019.103959861.davem@davemloft.net>
References: <2f3bf9a60806160351l3611d9f7jef90d51e257b059d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dotanba@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60922
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756544AbYFPWAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 18:00:19 -0400
In-Reply-To: <2f3bf9a60806160351l3611d9f7jef90d51e257b059d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dotan Barak" <dotanba@gmail.com>
Date: Mon, 16 Jun 2008 13:51:12 +0300

> I'm trying to use the I/OAT technology but i don't know if the the
> sent data used this technology.

Note that I/O AT is only used for receiving data over a socket,
not for sending.
