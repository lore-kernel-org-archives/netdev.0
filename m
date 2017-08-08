From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH v3 net-next 4/5] tcp: Adjust TCP ULP to defer to sockets
 ULP
Date: Tue, 08 Aug 2017 12:37:59 -0700
Message-ID: <598A1317.8000805@gmail.com>
References: <20170807172818.31855-1-tom@quantonium.net> <20170807172818.31855-5-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: rohit@quantonium.net, davejwatson@fb.com
To: Tom Herbert <tom@quantonium.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:37379 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752152AbdHHTiU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 15:38:20 -0400
Received: by mail-pg0-f65.google.com with SMTP id 83so3912215pgb.4
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 12:38:20 -0700 (PDT)
In-Reply-To: <20170807172818.31855-5-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2017 10:28 AM, Tom Herbert wrote:
> Fix TCP and TLS to use the newer ULP infrastructure in sockets.
> 
> Signed-off-by: Tom Herbert <tom@quantonium.net>
> ---

Looks OK to me.

Acked-by: John Fastabend <john.fastabend@gmail.com>
