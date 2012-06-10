From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH torvalds/linux.git] Make linux/tcp.h C++ friendly
 (trivial)
Date: Sat, 09 Jun 2012 21:26:53 -0700 (PDT)
Message-ID: <20120609.212653.1110875247901140795.davem@davemloft.net>
References: <20120609145303.3094919060E@elbrus2.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jkosina@suse.cz
To: ppluzhnikov@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32969 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796Ab2FJE06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2012 00:26:58 -0400
In-Reply-To: <20120609145303.3094919060E@elbrus2.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ppluzhnikov@google.com (Paul Pluzhnikov)
Date: Sat,  9 Jun 2012 07:53:03 -0700 (PDT)

> P.S. Google has blanket copyright assignment to FSF.

FSF assignments have no applicability with the Linux kernel.

This really eliminates the reason why I asked you to make
a fresh submission of the patch.

I asked you to do this so that I could just apply your
patch using "git am --signoff" but I can't, now I have
to edit out all of this irrelevant text you added to
the email.

I have to edit out this "P.S." thing, because it's irrelevant.

I have to edit out all of the trite things like "Thanks," too.

Oh well, II'll edit it up and apply your patch this time.

But for future submissions put only essential things into the email
content because that ends up in the commit message.  If you want to
say "extra" stuff say it after the "---" because things said after
"---" don't make it into the commit log message.
