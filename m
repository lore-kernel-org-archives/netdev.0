From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net] net: Allow flow dissector to handle non 4-byte
 aligned headers
Date: Sun, 31 Jan 2016 19:43:12 -0500
Message-ID: <20160201004312.GC31924@oracle.com>
References: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
 <1454286240.7627.160.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org, kernel-team@fb.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:51761 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932824AbcBAAnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 19:43:23 -0500
Content-Disposition: inline
In-Reply-To: <1454286240.7627.160.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/31/16 16:24), Eric Dumazet wrote:
> 
> But this test is absolutely useless, what about testing arches that
> actually care ?
> 

Yes, I plan to help test this out tomorrow, Tom suggested setting up
gre-teb between x86 and sparc. 

--Sowmini
