From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next 0/9] inet: frag: cleanup and update
Date: Mon, 28 Jul 2014 08:43:34 +0200
Message-ID: <20140728064332.GA9801@omega>
References: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:52071 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbaG1Gnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 02:43:41 -0400
Received: by mail-wi0-f176.google.com with SMTP id bs8so3838757wib.9
        for <netdev@vger.kernel.org>; Sun, 27 Jul 2014 23:43:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2014 at 04:50:28PM +0200, Nikolay Aleksandrov wrote:
> Hello,
> The end goal of this patchset is to remove the LRU list and to move the
> frag eviction to a work queue. It also does a couple of necessary cleanups
> and fixes.

For net/ieee802154/reassembly.c:

Acked-by: Alexander Aring <alex.aring@gmail.com>
