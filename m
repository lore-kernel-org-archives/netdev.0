From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: Re: [PATCH] NET: Officially deprecate "ether=" in favour of
 "netdev=".
Date: Thu, 15 Nov 2007 00:32:10 -0500 (EST)
Message-ID: <alpine.LFD.0.9999.0711150030380.20983@localhost.localdomain>
References: <alpine.LFD.0.9999.0711142318370.4120@localhost.localdomain> <473BD994.2070809@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux M68K mailing list <linux-m68k@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:40477 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbXKOFft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 00:35:49 -0500
In-Reply-To: <473BD994.2070809@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Nov 2007, Stephen Hemminger wrote:

... relevant patch snipped ...

> Why bother. I would removing it?

i tried that once, and a number of people promptly had kittens over
the thought of simply yanking a working kernel parameter without
giving everyone at least a year's notice.

rday

========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================
