From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] bpf: fix the printing of ifindex
Date: Wed, 02 Aug 2017 09:06:34 -0700
Message-ID: <5981F88A.90607@gmail.com>
References: <1501688632-2709-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: William Tu <u9012063@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:37373 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbdHBQGn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 12:06:43 -0400
Received: by mail-pg0-f54.google.com with SMTP id y129so22935872pgy.4
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 09:06:43 -0700 (PDT)
In-Reply-To: <1501688632-2709-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2017 08:43 AM, William Tu wrote:
> Save the ifindex before it gets zeroed so the invalid
> ifindex can be printed out.
> 
> Signed-off-by: William Tu <u9012063@gmail.com>
> ---


Thanks!

Acked-by: John Fastabend <john.fastabend@gmail.com>
