From: Hiroaki Shimoda <shimoda.hiroaki@gmail.com>
Subject: Re: [PATCH net-next] inet_diag: Remove _bh suffix in
 inet_diag_dump_reqs().
Date: Fri, 19 Jun 2015 19:34:02 +0900
Message-ID: <20150619193402.7c6d23018ebe410ed9cb95c1@gmail.com>
References: <1434627654-3630-1-git-send-email-shimoda.hiroaki@gmail.com>
	<1434696128.31511.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34265 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbbFSKeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 06:34:07 -0400
Received: by pabvl15 with SMTP id vl15so36616976pab.1
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 03:34:07 -0700 (PDT)
In-Reply-To: <1434696128.31511.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Jun 2015 23:42:08 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Sure, although this will soon be removed completely when SYN_RECV
> sockets will be stored in regular ehash table.

OK. Thank you for letting me know.
