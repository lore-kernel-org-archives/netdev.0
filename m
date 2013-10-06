From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IPv6 path MTU discovery broken
Date: Sun, 6 Oct 2013 14:48:19 +0200
Message-ID: <20131006124819.GB27852@sesse.net>
References: <20130927201420.GB12043@sesse.net>
 <20130928203318.GC23654@order.stressinduktion.org>
 <20131006120612.GA27852@sesse.net>
 <20131006124403.GA9295@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:38796 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115Ab3JFMs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Oct 2013 08:48:27 -0400
Content-Disposition: inline
In-Reply-To: <20131006124403.GA9295@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 06, 2013 at 02:44:03PM +0200, Hannes Frederic Sowa wrote:
> Do you know which remote IP address is part in the failing communication? Same
> as above?

It's in 2001:67c:a4:3::/64 or 2001:67c:a4:1::/64. Unsure which, because now
I rebooted the client for a different reason (giving it a different privacy
address and possibly subnet), and now it's unreproducible again...

/* Steinar */
-- 
Homepage: http://www.sesse.net/
