From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 1/2] IPv6: add "disable" module parameter support to ipv6.ko
Date: Wed, 04 Mar 2009 10:37:03 -0500
Message-ID: <49AEA01F.8050906@hp.com>
References: <49ADE95F.8060607@hp.com> <20090304.032145.115092643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: arvidjaar@mail.ru, vladislav.yasevich@hp.com,
	chuck.lever@oracle.com, tytso@mit.edu, Valdis.Kletnieks@vt.edu,
	rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:33084 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753036AbZCDPhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 10:37:08 -0500
In-Reply-To: <20090304.032145.115092643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Applied, but you have to do something about your email client
> and what it does to patches Brian.
> 
> Every line that starts with a single space then TABs was
> replaced with two space characters then the TABs.  Long
> lines were also chopped up.

Sorry, I'll blame it on git-imap-send/tbird :) - I just know how people hate 
attachments, I can play with the settings again.  I'll send it to myself first 
next time and see what gets corrupted, thanks for fixing it up.

I wish we didn't have to do this hack though...

-Brian
