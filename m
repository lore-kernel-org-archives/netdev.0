From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next v2 0/6] inet: frags: cleanup and kmem_cache use
Date: Fri, 1 Aug 2014 13:24:35 +0200
Message-ID: <20140801112433.GA12179@omega>
References: <1406888988-20742-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:53054 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832AbaHALYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 07:24:44 -0400
Received: by mail-we0-f176.google.com with SMTP id q58so4184073wes.35
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 04:24:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1406888988-20742-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 01, 2014 at 12:29:42PM +0200, Nikolay Aleksandrov wrote:
> Hello,
> This patchset does a couple of small cleanups in patches 1-5 and then in
> patch 06 it introduces the use of kmem_cache for allocation/freeing of
> inet_frag_queue+header objects.
> 

For net/ieee802154/reassembly.c:

Acked-by: Alexander Aring <alex.aring@gmail.com>
