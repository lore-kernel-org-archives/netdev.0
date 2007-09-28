From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] net: Add network namespace clone & unshare support.
Date: Thu, 27 Sep 2007 17:25:33 -0700
Message-ID: <20070927172533.1dd1db31.akpm@linux-foundation.org>
References: <m1k5qcjaiu.fsf@ebiederm.dsl.xmission.com>
	<20070927.124552.69400277.davem@davemloft.net>
	<m18x6rhfy0.fsf@ebiederm.dsl.xmission.com>
	<20070927.171053.39175054.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55135 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751862AbXI1A0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 20:26:11 -0400
In-Reply-To: <20070927.171053.39175054.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Sep 2007 17:10:53 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> > I will gladly do what I can, to help.  Working against 3 trees
> > development at the moment is a bit of a development challenge.
> 
> Andrew has to work against 30 or so

I wish!  A remerge presently involves pulling and merging 73 git trees, 9
quilt trees and maybe 1,500 -mm patches.

