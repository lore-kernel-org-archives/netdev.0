From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/2] bpf, s390: fix jit branch offset related to ldimm64
Date: Fri, 04 Aug 2017 15:52:47 +0200
Message-ID: <59847C2F.6010306@iogearbox.net>
References: <cover.1501848914.git.daniel@iogearbox.net> <a63b808ceaa481dfae896bcf611fc489fdc59080.1501848914.git.daniel@iogearbox.net> <20170804154420.6faae20a@TP-holzheu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@fb.com, netdev@vger.kernel.org
To: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42341 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752506AbdHDNwx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 09:52:53 -0400
In-Reply-To: <20170804154420.6faae20a@TP-holzheu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/04/2017 03:44 PM, Michael Holzheu wrote:
> Am Fri,  4 Aug 2017 14:20:54 +0200
> schrieb Daniel Borkmann <daniel@iogearbox.net>:
[...]
>
> What about "Cc: stable@vger.kernel.org"?

Handled by Dave, see also: Documentation/networking/netdev-FAQ.txt +117

Cheers,
Daniel
