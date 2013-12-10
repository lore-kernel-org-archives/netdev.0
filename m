From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC ] net: sched: tbf: fix the calculation of max_size
Date: Mon, 09 Dec 2013 18:39:10 -0800
Message-ID: <1386643150.30495.340.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386313205-87660-1-git-send-email-yangyingliang@huawei.com>
		 <1386313205-87660-2-git-send-email-yangyingliang@huawei.com>
		 <AE90C24D6B3A694183C094C60CF0A2F6026B7468@saturn3.aculab.com>
		 <52A5384A.8050106@huawei.com>
		 <AE90C24D6B3A694183C094C60CF0A2F6026B7471@saturn3.aculab.com>
		 <52A5B5D9.7000204@huawei.com> <52A5C12D.8080008@huawei.com>
	 <1386601926.30495.323.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52A67C88.8040606@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	David Laight <David.Laight@ACULAB.COM>, brouer@redhat.com,
	jpirko@redhat.com, jbrouer@redhat.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:63447 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857Ab3LJCjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:39:16 -0500
Received: by mail-pb0-f46.google.com with SMTP id md12so6601486pbc.19
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 18:39:16 -0800 (PST)
In-Reply-To: <52A67C88.8040606@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-10 at 10:29 +0800, Yang Yingliang wrote:

> Hmm, I cannot figure out why max_t, did you mean min_t?

probably !
