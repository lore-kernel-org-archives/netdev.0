From: Cong Wang <cwang@twopensource.com>
Subject: Re: Please backport dev_kfree_skb_any fixes for stable
Date: Fri, 27 Jun 2014 16:18:56 -0700
Message-ID: <CAHA+R7P556Rn22qS4+CJc-RXX8ozt5uUd=dE48hSpgV9r7kvyQ@mail.gmail.com>
References: <CAHA+R7N80Q6sh6ZjMM9B0rOUUx1YuDfE3OQGD+Av6+t7gz+MSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:50329 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754622AbaF0XS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 19:18:58 -0400
Received: by mail-lb0-f171.google.com with SMTP id s7so4503021lbd.30
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 16:18:56 -0700 (PDT)
In-Reply-To: <CAHA+R7N80Q6sh6ZjMM9B0rOUUx1YuDfE3OQGD+Av6+t7gz+MSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 19, 2014 at 4:48 PM, Cong Wang <cwang@twopensource.com> wrote:
> Hi, David
>
>
> Please consider to backport the following dev_kfree_skb_any
> commits for stable. They fix some annoying warnings for us.
>

Any response? It looks like they are still not in your stable queue.
Or do you have any objections?
