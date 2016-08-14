From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net v4 4/7] net_sched: move tc offload macros to pkt_cls.h
Date: Sun, 14 Aug 2016 07:03:01 -0400
Message-ID: <af5dd594-0818-9f87-32ed-cd58a5b0efaf@mojatatu.com>
References: <1471152902-12444-1-git-send-email-xiyou.wangcong@gmail.com>
 <1471152902-12444-5-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ido Schimmel <idosch@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36377 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964958AbcHNLDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 07:03:08 -0400
Received: by mail-qk0-f196.google.com with SMTP id v123so2339987qkh.3
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 04:03:07 -0700 (PDT)
In-Reply-To: <1471152902-12444-5-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-14 01:34 AM, Cong Wang wrote:
> struct tcf_exts belongs to filters, should not be visible
> to plain tc actions.
>
> Cc: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
