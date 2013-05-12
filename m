From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: [RFC 17/42] drivers/net/ethernet/renesas: don't check resource
 with devm_ioremap_resource
Date: Sun, 12 May 2013 11:42:07 +0200
Message-ID: <20130512094202.GA3039@katana>
References: <1368173847-5661-1-git-send-email-wsa@the-dreams.de>
 <1368173847-5661-18-git-send-email-wsa@the-dreams.de>
 <518EAB9B.8040106@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sauhun.de ([89.238.76.85]:52691 "EHLO pokefinder.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138Ab3ELJko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 May 2013 05:40:44 -0400
Content-Disposition: inline
In-Reply-To: <518EAB9B.8040106@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> You should really compile-test your patches.

Easier said than done with a cleanup series touching various platforms
and architectures. If there are already solutions how to find a .config
compiling the source file modified, I am all ears.

That being said, the actual mistake I did was embarassing, I agree. I am
sorry for that and will improve. And, doing things means doing mistakes,
too.

Regards,

   Wolfram
