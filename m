From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] ipip: fix a regression in ioctl
Date: Tue, 02 Jul 2013 14:38:44 +0800
Message-ID: <1372747124.13643.6.camel@cr0>
References: <CALnjE+qoo3D6YDpZogPq8LOJLZxoOTLa73WJFHnH2MbnFB2f7Q@mail.gmail.com>
	 <1372644681.2974.12.camel@cr0>
	 <CALnjE+q5AW+6hwViLgh8CKScwP0uZao8r75B8_9h1unqKduO-w@mail.gmail.com>
	 <20130701.233649.2100517070636126111.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1941 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750857Ab3GBGi4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jul 2013 02:38:56 -0400
In-Reply-To: <20130701.233649.2100517070636126111.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-01 at 23:36 -0700, David Miller wrote:
> From: Pravin Shelar <pshelar@nicira.com>
> >>
> > ok, Then we shld reset these fields before passing them to ip_tunnels layer.
> 
> Someone please respin this to clear the fields instead, thanks!

I will send v2.

Thanks!
