From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net 3/3] bpf: add test cases to bpf selftests to cover all
 access tests
Date: Sat, 21 Oct 2017 09:40:05 -0700
Message-ID: <a6992c8f-3ad1-f01d-3d17-7faec0ff44e5@gmail.com>
References: <cover.1508545543.git.daniel@iogearbox.net>
 <3bc01f5985324b0e233e86616f4fe171c0d4ca8b.1508545543.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, john.r.fastabend@gmail.com,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:49249 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932196AbdJUQkW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 12:40:22 -0400
Received: by mail-pf0-f181.google.com with SMTP id i5so14192514pfe.6
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2017 09:40:22 -0700 (PDT)
In-Reply-To: <3bc01f5985324b0e233e86616f4fe171c0d4ca8b.1508545543.git.daniel@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2017 05:34 PM, Daniel Borkmann wrote:
> Lets add test cases to cover really all possible direct packet
> access tests for good/bad access cases so we keep tracking them.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> ---

Acked-by: John Fastabend <john.fastabend@gmail.com>
