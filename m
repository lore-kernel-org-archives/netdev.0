From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] [IPV4] Reduce whitespaces in fib_rules.h.
Date: Thu, 13 Dec 2007 06:50:45 -0800 (PST)
Message-ID: <20071213.065045.189743239.davem@davemloft.net>
References: <20071213141842.GA9939@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48918
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754717AbXLMOus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 09:50:48 -0500
In-Reply-To: <20071213141842.GA9939@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 13 Dec 2007 17:18:42 +0300

> There are to many spaces between type and function name in the declaration
> of fib rules manipulation routines. Eat them and save a couple of lines.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

This is just noise and serves nothing other than to invite potential
patch conflicts which makes development harder.

If you happened to be changing these for other reasons, I'd say OK,
but not like this.
