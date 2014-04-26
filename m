From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] sched, act: allow to clear all actions as well
Date: Sat, 26 Apr 2014 07:40:47 -0400
Message-ID: <535B9B3F.9040506@mojatatu.com>
References: <1398459330-15598-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:58366 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbaDZLlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 07:41:17 -0400
Received: by mail-ie0-f179.google.com with SMTP id lx4so4693982iec.24
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2014 04:41:17 -0700 (PDT)
In-Reply-To: <1398459330-15598-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/14 16:55, Cong Wang wrote:
> From: Cong Wang <cwang@twopensource.com>
>
> When we change the list of action on a given filter, currently we don't
> change it to empty. This is a bug, we should allow to change to whatever
> users given.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>


Thanks Cong.
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
