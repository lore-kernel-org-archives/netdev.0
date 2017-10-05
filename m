From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v3 2/2] libbpf: use map_flags when creating maps
Date: Thu, 05 Oct 2017 21:26:12 +0200
Message-ID: <59D68754.7070407@iogearbox.net>
References: <20171005144158.14860-1-kraigatgoog@gmail.com> <20171005144158.14860-3-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chonggang Li <chonggangli@google.com>, netdev@vger.kernel.org
To: Craig Gallek <kraigatgoog@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36751 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751423AbdJET0R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 15:26:17 -0400
In-Reply-To: <20171005144158.14860-3-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2017 04:41 PM, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
>
> This is required to use BPF_MAP_TYPE_LPM_TRIE or any other map type
> which requires flags.
>
> Signed-off-by: Craig Gallek <kraig@google.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
