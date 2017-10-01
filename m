From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net: ipv4: remove fib_info arg to fib_check_nh
Date: Sun, 1 Oct 2017 13:44:32 +0300
Message-ID: <b7495ada-9a22-075c-65bb-dc20cb893ddf@cogentembedded.com>
References: <1506570119-17088-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:54359 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751021AbdJAKog (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 06:44:36 -0400
Received: by mail-lf0-f47.google.com with SMTP id d10so978346lfg.11
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 03:44:35 -0700 (PDT)
In-Reply-To: <1506570119-17088-1-git-send-email-dsahern@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 9/28/2017 6:41 AM, David Ahern wrote:

> fib_check_nh does not use the fib_info arg; remove t.

    s/t/it/. :-)

> Signed-off-by: David Ahern <dsahern@gmail.com>
[...]

MBR, Sergei
