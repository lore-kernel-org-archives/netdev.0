From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to prevent
 overflow
Date: Tue, 25 Apr 2017 18:42:44 +0300
Message-ID: <00e2b74b-69cd-07c5-6a0e-5b3e856a783e@cogentembedded.com>
References: <20170425140809.23881-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net,
        David.Laight@aculab.com, kernel-hardening@lists.openwall.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:35536 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1950564AbdDYPms (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:42:48 -0400
Received: by mail-lf0-f42.google.com with SMTP id 75so93008598lfs.2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 08:42:47 -0700 (PDT)
In-Reply-To: <20170425140809.23881-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 04/25/2017 05:08 PM, Jason A. Donenfeld wrote:

> This is a defense-in-depth measure in response to bugs like
> 4d6fa57b4dab0d77f4d8e9d9c73d1e63f6fe8fee.

    You need to also specify the summary line enclosed in (""). And it's 
enough to specify 12 digits of SHA1 ID...

> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
[...]

MBR, Sergei
