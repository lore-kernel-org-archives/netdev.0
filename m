From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/6] isdn: hisax, fix lock imbalance
Date: Tue, 22 Sep 2009 14:34:46 -0700 (PDT)
Message-ID: <20090922.143446.233247853.davem@davemloft.net>
References: <200909181953.n8IJr1Wl026154@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org, jirislaby@gmail.com,
	Karsten-Keil@t-online.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39996
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751594AbZIVVe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 17:34:27 -0400
In-Reply-To: <200909181953.n8IJr1Wl026154@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm hoping Karsten will pick these up.

But I'm not optimistic as I've been waiting weeks for some
other ISDN fixes to get looked at :-/
