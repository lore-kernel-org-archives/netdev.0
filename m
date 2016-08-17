From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic TPROXY , vanilla 4.7.1
Date: Wed, 17 Aug 2016 09:48:18 -0700
Message-ID: <1471452498.29842.7.camel@edumazet-glaptop3.roam.corp.google.com>
References: <627722c51d9ce454dfaf1a79519ceb59@nuclearcat.com>
	 <1471448525.29842.1.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1471449871.29842.3.camel@edumazet-glaptop3.roam.corp.google.com>
	 <09c3ca74357572464b5ff280f1cd0ddc@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33161 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513AbcHQQsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 12:48:20 -0400
In-Reply-To: <09c3ca74357572464b5ff280f1cd0ddc@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-17 at 19:44 +0300, Denys Fedoryshchenko wrote:

> Yes, everything fine after patch!
> Thanks a lot

Perfect, thanks for testing, I am sending the official patch.
