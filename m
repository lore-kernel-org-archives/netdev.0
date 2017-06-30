From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v5 06/16] bpf: Sample bpf program to set initial
 window
Date: Sat, 01 Jul 2017 01:35:58 +0200
Message-ID: <5956E05E.2040509@iogearbox.net>
References: <20170630200706.4183158-1-brakmo@fb.com> <20170630200706.4183158-7-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57592 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751680AbdF3XgB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 19:36:01 -0400
In-Reply-To: <20170630200706.4183158-7-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/30/2017 10:06 PM, Lawrence Brakmo wrote:
> The sample bpf program, tcp_rwnd_kern.c, sets the initial
> advertized window to 40 packets in an environment where
> distinct IPv6 prefixes indicate that both hosts are not
> in the same data center.
>
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
