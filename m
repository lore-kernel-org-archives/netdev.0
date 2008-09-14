From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ethtool: Add register dump support for all r8169 driver
 cards
Date: Sat, 13 Sep 2008 22:12:47 -0400
Message-ID: <48CC731F.9020000@garzik.org>
References: <76366b180803261736y3ff4b34eofef2f48174547995@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Andrew Paprocki <andrew@ishiboo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36713 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753247AbYINCMu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 22:12:50 -0400
In-Reply-To: <76366b180803261736y3ff4b34eofef2f48174547995@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Paprocki wrote:
> This adds all MAC versions currently found in the r8169 to the RealTek
> table and modifies the dump logic to handle card versions >= RTL8169
> instead of specifically looking at the few previously supported cards.
> 
> Signed-off-by: Andrew Paprocki <andrew@ishiboo.com>

applied


