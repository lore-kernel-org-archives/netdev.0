From: Paul Menzel <pmenzel@molgen.mpg.de>
Subject: Cherry pick commit *net: better skb->sender_cpu and skb->napi_id
 cohabitation* to 4.4 series?
Date: Thu, 1 Jun 2017 14:43:30 +0200
Message-ID: <987d9047-08ac-0d53-2d1f-ef9189988ee2@molgen.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        it+linux-netdev@molgen.mpg.de
To: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.molgen.mpg.de ([141.14.17.11]:49025 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751083AbdFAMnc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 08:43:32 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David, dear Eric,


We noticed, that we manually apply commit 52bd2d62ce67 (net: better 
skb->sender_cpu and skb->napi_id cohabitation), present since v4.5-rc1, 
to our Linux 4.4 images.

Would it be useful to have it included in the 4.4 series?


Kind regards,

Paul
