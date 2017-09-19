From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/3] bpf: Test deletion in BPF_MAP_TYPE_LPM_TRIE
Date: Tue, 19 Sep 2017 18:12:53 +0200
Message-ID: <59C14205.3090807@iogearbox.net>
References: <20170918193057.37644-1-kraigatgoog@gmail.com> <20170918193057.37644-4-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Craig Gallek <kraigatgoog@gmail.com>,
        Daniel Mack <daniel@zonque.org>,
        Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47168 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751548AbdISQM5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 12:12:57 -0400
In-Reply-To: <20170918193057.37644-4-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2017 09:30 PM, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
>
> Extend the 'random' operation tests to include a delete operation
> (delete half of the nodes from both lpm implementions and ensure
> that lookups are still equivalent).
>
> Also, add a simple IPv4 test which verifies lookup behavior as nodes
> are deleted from the tree.
>
> Signed-off-by: Craig Gallek <kraig@google.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
