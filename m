From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: give prequeue mode some care
Date: Thu, 28 Apr 2016 15:00:45 -0700
Message-ID: <1461880845.5535.122.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461777145.5535.77.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160428.171514.1303373912379094235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35283 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbcD1WAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 18:00:46 -0400
Received: by mail-pa0-f47.google.com with SMTP id iv1so37365024pac.2
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 15:00:46 -0700 (PDT)
In-Reply-To: <20160428.171514.1303373912379094235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-28 at 17:15 -0400, David Miller wrote:

> There was a conflict due to the stats macro renaming, but that was trivial
> to resolve so I did it.
> 
> Applied, thanks Eric.
Ah great, I was preparing a V2, you were fast David.

Thanks
