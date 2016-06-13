From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] act_police: rename tcf_act_police_locate() to
 tcf_act_police_init()
Date: Mon, 13 Jun 2016 17:54:35 -0400
Message-ID: <575F2B9B.50109@mojatatu.com>
References: <1465840064-7650-1-git-send-email-xiyou.wangcong@gmail.com>
 <1465840064-7650-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:36387 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932757AbcFMVyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 17:54:37 -0400
Received: by mail-io0-f175.google.com with SMTP id n127so132164521iof.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 14:54:36 -0700 (PDT)
In-Reply-To: <1465840064-7650-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-13 01:47 PM, Cong Wang wrote:
> This function is just ->init(), rename it to make it obvious.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
