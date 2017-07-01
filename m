From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v6 00/16] bpf: Adds support for sock_ops
Date: Sun, 02 Jul 2017 01:01:24 +0200
Message-ID: <595829C4.90105@iogearbox.net>
References: <20170701030255.1931076-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51897 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752118AbdGAXB0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 19:01:26 -0400
In-Reply-To: <20170701030255.1931076-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2017 05:02 AM, Lawrence Brakmo wrote:
[...]
> v6: fixes to BPF helper function setsockopt (possible NULL deferencing, etc.)

Thanks for fixing up, BPF side looks good to me.
