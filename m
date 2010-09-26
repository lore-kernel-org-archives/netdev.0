From: David Miller <davem@davemloft.net>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 15:38:32 -0700 (PDT)
Message-ID: <20100926.153832.115943505.davem@davemloft.net>
References: <20100926131717.GA13046@1wt.eu>
	<20100926.151346.112585478.davem@davemloft.net>
	<20100926223448.GF12373@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36728
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932424Ab0IZWiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 18:38:12 -0400
In-Reply-To: <20100926223448.GF12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Mon, 27 Sep 2010 00:34:48 +0200

> I don't see what is being violated nor what reliability has been
> compromised.

The TCP protcol's obligation to reliably deliver data between
two applications, that is what has been violated.

You don't have to like this, but you certainly must cope with it
in your applications :-)
