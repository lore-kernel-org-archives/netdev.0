From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 3/4] myri10ge - Driver core
Date: Sat, 20 May 2006 02:01:43 +0200
Message-ID: <200605200201.43462.ak@suse.de>
References: <20060517220218.GA13411@myri.com> <200605180108.32949.arnd@arndb.de> <446E51AB.9080703@myri.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	gallatin@myri.com, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40110 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751437AbWETABt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 May 2006 20:01:49 -0400
To: Brice Goglin <brice@myri.com>
In-Reply-To: <446E51AB.9080703@myri.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> We have tried :) But there is no nice way to split this code. So I guess
> we will have to keep it like this.

You could shorten the #define names a bit (s/MYRI10GE_MCP_ETHER_/MCP_/)  Then everything 
will fit better.

-Andi
