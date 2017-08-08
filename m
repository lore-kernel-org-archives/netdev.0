From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH v3 net-next 1/5] proto_ops: Fixes to adding locked version
 of sendmsg/page
Date: Tue, 08 Aug 2017 02:55:06 -0700
Message-ID: <59898A7A.2040107@gmail.com>
References: <20170807172818.31855-1-tom@quantonium.net> <20170807172818.31855-2-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: rohit@quantonium.net, davejwatson@fb.com
To: Tom Herbert <tom@quantonium.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35047 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751868AbdHHJzQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 05:55:16 -0400
Received: by mail-pf0-f172.google.com with SMTP id t86so12633202pfe.2
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 02:55:16 -0700 (PDT)
In-Reply-To: <20170807172818.31855-2-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2017 10:28 AM, Tom Herbert wrote:
> Fixes for two issues pointed out by John Fastabend.
> 
> Fixes: 306b13eb3cf9515a ("proto_ops: Add locked held versions of sendmsg and sendpage")
> Reported-by: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Tom Herbert <tom@quantonium.net>
> ---

This is the same patch as the one in my RFC series so its an ack from me.

Acked-by: John Fastabend <john.fastabend@gmail.com>
