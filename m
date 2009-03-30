From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH] netfilter: finer grained nf_conn locking
Date: Mon, 30 Mar 2009 21:38:09 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0903302131390.13325@ask.diku.dk>
References: <20090218051906.174295181@vyatta.com> <20090218052747.679540125@vyatta.com>
 <499BDB5D.2050105@trash.net> <499C1894.7060400@cosmosbay.com>
 <49CE568A.9090104@cosmosbay.com> <49D11635.2050809@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:48357 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760081AbZC3TiR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2009 15:38:17 -0400
In-Reply-To: <49D11635.2050809@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Eric Dumazet wrote:
>>  "tbench 8" results on my 8 core machine (32bit kernel, with
>>  conntracking on) : 2319 MB/s instead of 2284 MB/s

How do you achieve this impressing numbers?
Is it against localhost? (10Gbit/s is max 1250 MB/s)

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
