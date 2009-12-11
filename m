From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-ipv4-tcp.c-fix-warning-from-older-compilers.patch
Date: Fri, 11 Dec 2009 14:25:45 -0800 (PST)
Message-ID: <20091211.142545.186399947.davem@davemloft.net>
References: <20091211065011.GA6409@ff.dom.local>
	<4B226A79.1070900@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, eric.dumazet@gmail.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59558
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762711AbZLKWZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 17:25:39 -0500
In-Reply-To: <4B226A79.1070900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Fri, 11 Dec 2009 10:51:21 -0500

> Jarek Poplawski wrote:
>>>> This is not necessary, David already _did_ the thing, and _told_ so.
>> But David _did_ forget to _send_ the thing to the list. ;-)
>> 
> Aha, so it wasn't a local problem.  Thanks!

I didn't necessarily have to, I stated exactly in the thread with
Andrew Morton what change I was going to make in my tree to resolve
this.

If you're really interested in following development and generating
correct current patches to the project, you should follow the
appropriate GIT tree.
