From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v5] net: ipv6: fix code style error and warning
 of ndisc.c
Date: Sun, 21 May 2017 10:17:47 -0600
Message-ID: <77510dfe-4fc7-4446-9f1a-aea52342ecd1@gmail.com>
References: <1495328154-18653-1-git-send-email-cugyly@163.com>
 <1495382708.2093.10.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: Joe Perches <joe@perches.com>, yuan linyu <cugyly@163.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33361 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751583AbdEUQRu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 12:17:50 -0400
Received: by mail-pg0-f65.google.com with SMTP id s62so15031102pgc.0
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 09:17:49 -0700 (PDT)
In-Reply-To: <1495382708.2093.10.camel@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/21/17 10:05 AM, Joe Perches wrote:
> But really, why bother?
> 
> Just because checkpatch bleats some message doesn't
> mean it _has_ to be fixed.
> 
> Please strive to make the code more readable and
> intelligible for _humans_.  Compilers don't care.

+1

broad cleanups like this make 'git blame' harder to use to find root causes.
