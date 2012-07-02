From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] ieee802154: sparse warnings: make symbols
 static
Date: Mon, 02 Jul 2012 09:13:28 +0200
Message-ID: <1341213208.5269.11.camel@edumazet-glaptop>
References: <1341209912-6030-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <1341209912-6030-2-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <1341211072.5269.0.camel@edumazet-glaptop>
	 <1341211476.5269.2.camel@edumazet-glaptop>
	 <1341211751.5269.6.camel@edumazet-glaptop>
	 <CAJmB2rDB6McXg=O_z-M3xFa0OrB5hkTWT=ZHM975GDTPvuGjtQ@mail.gmail.com>
	 <1341212942.5269.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, dbaryshkov@gmail.com
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54723 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932213Ab2GBHNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 03:13:30 -0400
Received: by eeit10 with SMTP id t10so1931689eei.19
        for <netdev@vger.kernel.org>; Mon, 02 Jul 2012 00:13:29 -0700 (PDT)
In-Reply-To: <1341212942.5269.10.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-02 at 09:09 +0200, Eric Dumazet wrote:
> mething...
> 
> - initialize frame->lock

or better, remove lock from struct lowpan_fragment
