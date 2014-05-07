From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 0/3] bonding: slight optimization and cleanup
Date: Wed, 7 May 2014 15:27:58 +0200
Message-ID: <20140507132758.GQ6295@redhat.com>
References: <1399434319-7300-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: fubar@us.ibm.com, andy@greyhouse.net, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42687 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933017AbaEGN2V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2014 09:28:21 -0400
Content-Disposition: inline
In-Reply-To: <1399434319-7300-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 07, 2014 at 11:45:16AM +0800, Ding Tianhong wrote:
>Ding Tianhong (3):
>  bonding: remove the unnecessary struct bond_net
>  bonding: simplify the slave_do_arp_validate_only()
>  bonding: remove the unused macro


Except that remark about first patch - looks good to me.

>
> drivers/net/bonding/bond_main.c |  4 ++--
> drivers/net/bonding/bonding.h   | 23 +++++++++--------------
> 2 files changed, 11 insertions(+), 16 deletions(-)
>
>-- 
>1.8.0
>
>
