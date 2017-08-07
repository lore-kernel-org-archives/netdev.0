From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] selftests: bpf: add a test for XDP redirect
Date: Mon, 07 Aug 2017 16:03:37 -0700
Message-ID: <5988F1C9.1080405@gmail.com>
References: <1502136882-40204-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>
To: William Tu <u9012063@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36738 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751875AbdHGXDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 19:03:54 -0400
Received: by mail-pf0-f173.google.com with SMTP id c28so6954643pfe.3
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 16:03:54 -0700 (PDT)
In-Reply-To: <1502136882-40204-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2017 01:14 PM, William Tu wrote:
> Add test for xdp_redirect by creating two namespaces with two
> veth peers, then forward packets in-between.
> 
> Signed-off-by: William Tu <u9012063@gmail.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: John Fastabend <john.fastabend@gmail.com>
> ---

Thanks for doing this.

Acked-by: John Fastabend <john.fastabend@gmail.com>
