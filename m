From: Joe Perches <joe@perches.com>
Subject: Re: net-2.6.25 being rebased...
Date: Tue, 11 Dec 2007 13:04:59 -0800
Message-ID: <1197407100.4911.150.camel@localhost>
References: <20071211.092638.148402625.davem@davemloft.net>
	 <20071211.115619.199600421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2471 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750749AbXLKVFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 16:05:04 -0500
In-Reply-To: <20071211.115619.199600421.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2007-12-11 at 11:56 -0800, David Miller wrote:
> The rebase of net-2.6.25 is complete

I have an earlier unmodified git repository of net-2.6.25.
Does anyone know the appropriate git commands to resync
to the rebased content?

$ git branch
* master
$ git-pull
[...]
Automatic merge failed; fix conflicts and then commit the result.


