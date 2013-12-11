From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v7 0/2] net: sched: fix two issues
Date: Wed, 11 Dec 2013 11:39:07 -0800
Message-ID: <1386790747.30495.381.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386658768-29584-1-git-send-email-yangyingliang@huawei.com>
	 <20131211.142032.645385003264171429.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: yangyingliang@huawei.com, netdev@vger.kernel.org,
	brouer@redhat.com, jpirko@redhat.com, jbrouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:51941 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262Ab3LKTjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 14:39:08 -0500
Received: by mail-pd0-f173.google.com with SMTP id p10so10078188pdj.4
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 11:39:08 -0800 (PST)
In-Reply-To: <20131211.142032.645385003264171429.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-11 at 14:20 -0500, David Miller wrote:
> From: Yang Yingliang <yangyingliang@huawei.com>
> Date: Tue, 10 Dec 2013 14:59:26 +0800
> 
> > fix calculation of max_size in tbf
> > fix quantum calculation introduced by 64bit rates.
> 
> Eric does this series look good to you now?

Yes it seems good now, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
