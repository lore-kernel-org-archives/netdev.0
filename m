From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 0/2] Delete obsolete wanrouter support
Date: Fri, 01 Feb 2013 16:35:12 -0800
Message-ID: <1359765312.17807.19.camel@joe-AO722>
References: <1359761422-27629-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46751 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756243Ab3BBAfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 19:35:15 -0500
In-Reply-To: <1359761422-27629-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-01 at 18:30 -0500, Paul Gortmaker wrote:
> The removal of wanrouter code was originally listed in the (now
> gone) feature removal file since May 2012, and an RFC of the
> deletion was posted[1] in late 2012.
[]
> In addition to resolving the build failures of the RFC by keeping
> stub headers, this also splits the change into two parts, just like
> the token ring removal did.  Part #1 decouples the mainline kernel
> from the expired subsystem, and part #2 does the large scale
> deletion of the subsystem content.

Thanks Paul.
