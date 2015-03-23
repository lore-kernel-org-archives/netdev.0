From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: One way TCP bottleneck over 6 x Gbit tecl aggregated link //
 Kernel issue
Date: Sun, 22 Mar 2015 19:33:17 -0700
Message-ID: <1427077997.25985.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <201503210110.48980.wrosner@tirnet.de>
	 <1427043294.25985.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <201503222148.00332.wrosner@tirnet.de>
	 <201503230157.46489.wrosner@tirnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Wolfgang Rosner <wrosner@tirnet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:35915 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbbCWCdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 22:33:19 -0400
Received: by igbud6 with SMTP id ud6so30954158igb.1
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 19:33:19 -0700 (PDT)
In-Reply-To: <201503230157.46489.wrosner@tirnet.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-23 at 01:57 +0100, Wolfgang Rosner wrote:

> 
> Are you ready to assist me on this track?

First check if the problem is already solved, using this git tree ?

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git
