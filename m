From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] gtp: put back reference to netns when not
 required anymore
Date: Thu, 12 May 2016 11:37:12 -0700
Message-ID: <CAM_iQpVb1wfmAN_zXg2utpaG7uQdh-0jz2NCuTMdve6T1XujUQ@mail.gmail.com>
References: <1463066191-20748-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:36729 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752779AbcELShc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 14:37:32 -0400
Received: by mail-yw0-f193.google.com with SMTP id u62so8548088ywe.3
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 11:37:32 -0700 (PDT)
In-Reply-To: <1463066191-20748-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 12, 2016 at 8:16 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> This patch fixes a netns leak.
>
> Fixes: 93edb8c7f94f ("gtp: reload GTPv1 header after pskb_may_pull()")
> Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks.
