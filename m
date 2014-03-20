From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] tcp: syncookies: do not use getnstimeofday()
Date: Thu, 20 Mar 2014 13:07:39 -0700
Message-ID: <1395346059.9114.95.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395261524.9114.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1395263181.9114.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1395288141.9114.82.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140320.153645.1726836204043973392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:40452 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757901AbaCTUHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 16:07:41 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so1384002pdj.4
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 13:07:41 -0700 (PDT)
In-Reply-To: <20140320.153645.1726836204043973392.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-20 at 15:36 -0400, David Miller wrote:

> This applies cleanly to net-next, but with this Fixes: tag I sort of
> suspect you are targetting this at net instead?
> 
> Please be explicit as to what the target tree is when submitting
> patches in the future.

Well, I've always tagged net-next patches with net-next, and used no tag
for fixes.

If you want me to add net tag, I am totally fine.

So yes, this was a fix for net tree, but there is no hurry if you
applied to net-next its also fine.

Thanks
