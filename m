From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] tlan: Code cleanup: checkpatch.pl is relatively
 happy now.
Date: Mon, 24 Jan 2011 15:07:22 -0800 (PST)
Message-ID: <20110124.150722.260102248.davem@davemloft.net>
References: <4D39F3A7.9050106@iki.fi>
	<1295643571-21216-1-git-send-email-sakari.ailus@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chessman@tux.org, joe@perches.com
To: sakari.ailus@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33106
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752596Ab1AXXGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 18:06:48 -0500
In-Reply-To: <1295643571-21216-1-git-send-email-sakari.ailus@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sakari Ailus <sakari.ailus@iki.fi>
Date: Fri, 21 Jan 2011 22:59:30 +0200

> - Remove CamelCase.
> - Convert hexadecimals to lower case.
> - Remove useless comments. Tlan driver contained a name of the function at
>   the end of it in a comment. Remove those comments.
> - Remove local typedefs. Use real types instead of typedefs in code.
> - Resolve space issues and reindent.
> - One warning remain, it's a case where printing a single line involves a
>   number of printk()s.
> 
> Signed-off-by: Sakari Ailus <sakari.ailus@iki.fi>

Applied.
