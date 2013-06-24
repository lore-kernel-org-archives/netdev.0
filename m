From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: gre: fix a possible skb leak
Date: Mon, 24 Jun 2013 16:39:30 +0200
Message-ID: <20130624143930.GB28057@redhat.com>
References: <1372080360.3301.61.camel@edumazet-glaptop>
 <20130624140359.GA28057@redhat.com>
 <1372084560.3301.68.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57228 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779Ab3FXOjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 10:39:52 -0400
Content-Disposition: inline
In-Reply-To: <1372084560.3301.68.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 24, 2013 at 07:36:00AM -0700, Eric Dumazet wrote:
>On Mon, 2013-06-24 at 16:03 +0200, Veaceslav Falico wrote:
>
>> Maybe we can also use it here (build-tested only):
>
>Sure, but it will be done later on net-next
>
>This patch is a stable candidate, so I made a somewhat minimal change

Makes sense, didn't realize that it's for net, not net-next.

Thank you!

>
>
>
