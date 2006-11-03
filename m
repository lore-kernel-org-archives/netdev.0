From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: New stuff in wireless-dev, wireless developers please pull...
Date: Fri, 03 Nov 2006 09:44:52 +0100
Message-ID: <1162543492.2923.6.camel@ux156>
References: <20061103043024.GF2989@tuxdriver.com>
	 <200611030142.09303.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:10701 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1752021AbWKCInr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 03:43:47 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200611030142.09303.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-11-03 at 01:42 -0500, Michael Wu wrote:

> This is with cfg80211 turned off. 

wext-old.c shouldn't be compiled then. Must be some Makefile bug, I'll
look into it.

johannes
