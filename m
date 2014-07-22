From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] sock: remove skb argument from sk_rcvqueues_full
Date: Tue, 22 Jul 2014 18:59:06 +0400
Message-ID: <53CE7C3A.3000502@cogentembedded.com>
References: <1406036172-16573-1-git-send-email-sorin@returnze.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, davem@davemloft.net
To: Sorin Dumitru <sorin@returnze.ro>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:38460 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755031AbaGVO7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 10:59:08 -0400
Received: by mail-la0-f53.google.com with SMTP id gl10so5960628lab.26
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 07:59:06 -0700 (PDT)
In-Reply-To: <1406036172-16573-1-git-send-email-sorin@returnze.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07/22/2014 05:36 PM, Sorin Dumitru wrote:

> It hasn't been used since commit 0fd7bac.

    Please also specify that commit's summary line in parens.

> Signed-off-by: Sorin Dumitru <sorin@returnze.ro>

WBR, Sergei
