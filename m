From: David Miller <davem@davemloft.net>
Subject: Re: Please backport dev_kfree_skb_any fixes for stable
Date: Fri, 27 Jun 2014 16:38:13 -0700 (PDT)
Message-ID: <20140627.163813.1794281555636065922.davem@davemloft.net>
References: <CAHA+R7N80Q6sh6ZjMM9B0rOUUx1YuDfE3OQGD+Av6+t7gz+MSQ@mail.gmail.com>
	<CAHA+R7P556Rn22qS4+CJc-RXX8ozt5uUd=dE48hSpgV9r7kvyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbaF0XiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 19:38:14 -0400
In-Reply-To: <CAHA+R7P556Rn22qS4+CJc-RXX8ozt5uUd=dE48hSpgV9r7kvyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Fri, 27 Jun 2014 16:18:56 -0700

> On Thu, Jun 19, 2014 at 4:48 PM, Cong Wang <cwang@twopensource.com> wrote:
>> Hi, David
>>
>>
>> Please consider to backport the following dev_kfree_skb_any
>> commits for stable. They fix some annoying warnings for us.
>>
> 
> Any response? It looks like they are still not in your stable queue.
> Or do you have any objections?

I'm too busy with other things, I'll get to it by next week.
