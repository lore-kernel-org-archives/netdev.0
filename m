From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: remove internal use of TC_POLICE_*
Date: Mon, 13 Jun 2016 17:54:02 -0400
Message-ID: <575F2B7A.6040006@mojatatu.com>
References: <1465840064-7650-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:33209 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598AbcFMVyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 17:54:04 -0400
Received: by mail-io0-f178.google.com with SMTP id d2so44851406iof.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 14:54:04 -0700 (PDT)
In-Reply-To: <1465840064-7650-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-13 01:47 PM, Cong Wang wrote:
> These should be gone when we removed CONFIG_NET_CLS_POLICE.
> We can not totally remove them since they are exposed
> to userspace.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
