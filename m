From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH]: Eliminate fast-path print_mac() pr_debug()'s.
Date: Tue, 08 Apr 2008 17:08:46 -0700
Message-ID: <1207699726.1020.157.camel@localhost>
References: <20080408.165453.215068738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:4744 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbYDIAJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 20:09:09 -0400
In-Reply-To: <20080408.165453.215068738.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-04-08 at 16:54 -0700, David Miller wrote:
> Patrick, this is what I checked in to net-2.6, based upon your list.
[]
> Joe, [] Thanks for wasting part of my afternoon when I already
> am bombed with an enormous backlog of other work :-/

Your choice, your time.

Patrick's list was overly broad.
I asked for and received clarification.

If you'd have waited about 1/2 hour you would have received
the change I had already done which fixes just the fast path
pr_debug calls rather than what you did, which touches a
bunch of not fast path printks.

regards, Joe

