From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next 3/7] inetpeer: use generic union inet_addr
Date: Tue, 23 Jul 2013 10:05:31 +0800
Message-ID: <1374545131.24933.4.camel@cr0>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
	 <1374476713-8838-4-git-send-email-amwang@redhat.com>
	 <1374506315.4990.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31196 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751135Ab3GWCFm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 22:05:42 -0400
In-Reply-To: <1374506315.4990.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 08:18 -0700, Eric Dumazet wrote:
> On Mon, 2013-07-22 at 15:05 +0800, Cong Wang wrote:
> > From: Cong Wang <amwang@redhat.com>
> > 
> > struct inetpeer_addr is pretty similar to generic union inet_addr,
> > therefore can be safely converted to it.
> 
> Its 'safe' but adds 50% increase for struct tcp_metrics_block
> 
> I fail to see this mentioned in the changelog.

I asked you in RFC, but you don't give me any response, this is the
reason. :)

> I guess its no big deal, but why do you think this code used hand coded
> functions instead of generic ?
> 
> 
> 

I don't understand what you are asking here, seems totally unrelated
with the point you raised above, therefore I am completely confused...

Thanks.
