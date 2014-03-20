From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] tcp: syncookies: do not use getnstimeofday()
Date: Thu, 20 Mar 2014 13:37:41 -0700
Message-ID: <1395347861.9114.96.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395288141.9114.82.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140320.153645.1726836204043973392.davem@davemloft.net>
	 <1395346059.9114.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140320.161619.826791792330039198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:58976 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759898AbaCTUhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 16:37:43 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so1472930pad.0
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 13:37:42 -0700 (PDT)
In-Reply-To: <20140320.161619.826791792330039198.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-20 at 16:16 -0400, David Miller wrote:
> The confusion came mostly because it applied perfectly to net-next, but
> with fuzz to plain net. :)

My bad, you are totally right, I forgot to double check.

Sorry for the confusion.
