From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH v2 0/8] some netpoll and netconsole fixes
Date: Tue, 07 Aug 2012 14:58:41 +0800
Message-ID: <1344322721.6917.10.camel@cr0>
References: <1344263012-4031-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40342 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751316Ab2HGG6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2012 02:58:47 -0400
In-Reply-To: <1344263012-4031-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-06 at 22:23 +0800, Cong Wang wrote:
> V2:
> * update patch 1/8 as Eric suggested
> * drop the bridge patch, add comments instead
> * add patch 8/8
> 

Hi, David,

Please do _not_ apply this patchset, I plan to add 2 more patches,
because I found another issue of netpoll.

I will send V3 soon.

Thanks!
