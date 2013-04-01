From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next] core: should call pskb_expand_head if skb
 header is cloned in skb_gso_segment in rx path
Date: Mon, 01 Apr 2013 10:18:14 +0800
Message-ID: <1364782694.17431.7.camel@cr0>
References: <1364376845-5000-1-git-send-email-roy.qing.li@gmail.com>
	 <20130329.145947.1829620308225114250.davem@davemloft.net>
	 <CAJFZqHxBWtoiDBP36vkaGJ-sHn5svFjcJ_g-BJcES+ebxFbsCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: RongQing Li <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46878 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754589Ab3DACSZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Mar 2013 22:18:25 -0400
In-Reply-To: <CAJFZqHxBWtoiDBP36vkaGJ-sHn5svFjcJ_g-BJcES+ebxFbsCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-01 at 10:07 +0800, RongQing Li wrote:
> Hi Cong:
> 
> Could you give some comments for this patch?

I don't see the original path, sorry.
