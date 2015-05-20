From: Thomas Graf <tgraf@suug.ch>
Subject: Re: netlink: Disable insertions/removals during rehash
Date: Thu, 21 May 2015 01:53:46 +0200
Message-ID: <20150520235346.GA22074@pox.localdomain>
References: <20150514025333.GA3853@gondor.apana.org.au>
 <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514033448.GA5080@gondor.apana.org.au>
 <1431575890.27831.34.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431576818.27831.36.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514041628.GA5428@gondor.apana.org.au>
 <20150514042151.GA5482@gondor.apana.org.au>
 <20150514055824.GB6058@gondor.apana.org.au>
 <1431614276.27831.57.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150515000647.GA13821@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34094 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753452AbbETXxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 19:53:49 -0400
Received: by wicmc15 with SMTP id mc15so2726382wic.1
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 16:53:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150515000647.GA13821@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/15 at 08:06am, Herbert Xu wrote:
> On Thu, May 14, 2015 at 07:37:56AM -0700, Eric Dumazet wrote:
> >
> > This solves the corruption thanks Herbert.
> 
> Great.
> 
> > But wasn't rhashtable meant to be faster ? ;)
> 
> Is it, that's news to me :)

Eric, can you share the scripts you used to test this?
