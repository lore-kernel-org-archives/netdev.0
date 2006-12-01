From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/2][GENETLINK] add cmd dump completion
Date: Fri, 1 Dec 2006 13:50:02 +0100
Message-ID: <20061201125002.GF8693@postel.suug.ch>
References: <1164972828.3562.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:25278 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1031318AbWLAMtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 07:49:41 -0500
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1164972828.3562.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-12-01 06:33
> Sorry, subject was a little messed in the previous one, but should
> be fine going forward ..
> 
> cheers,
> jamal
> 

> [GENETLINK] add cmd dump completion
> 
> Remove assumption that generic netlink commands cannot have dump
> completion callbacks.

This looks good.
