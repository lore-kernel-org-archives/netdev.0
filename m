From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v6 3/3] ipv6: tcp_ipv6 policy route issue
Date: Fri, 11 Apr 2014 13:21:05 +0900
Message-ID: <CAKD1Yr1O_6-QGL=kaGz9PyPH4NC4C52qC-PXdQDvL4hL-6_Eqw@mail.gmail.com>
References: <1396056451-5600-1-git-send-email-wangyufen@huawei.com>
 <1396056451-5600-4-git-send-email-wangyufen@huawei.com> <CAKD1Yr1Qkc6OP_6Oj7x1S0u9QWS5HP17rDAo=_kT8kHm_qPf5Q@mail.gmail.com>
 <20140410215708.GJ27255@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Lorenzo Colitti <lorenzo@google.com>,
	Wangyufen <wangyufen@huawei.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:52650 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbaDKEV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 00:21:26 -0400
Received: by mail-ie0-f175.google.com with SMTP id to1so4890135ieb.20
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2014 21:21:26 -0700 (PDT)
In-Reply-To: <20140410215708.GJ27255@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2014 at 6:57 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> > If I am correct, then I'm happy to send out the trivial patch to fix
> > this. (Against what? net? net-next when the tree reopens?)
>
> -net tree is always open and I would welcome a patch very much.

Ack. I sent out http://patchwork.ozlabs.org/patch/338343/ .
