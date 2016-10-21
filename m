From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] bpf: add helper for retrieving current
 numa node id
Date: Fri, 21 Oct 2016 04:29:51 -0700
Message-ID: <1477049391.7065.52.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1477043972.git.daniel@iogearbox.net>
         <46dd208fee014c0837d750ffa13e625c6f4ee53c.1477043972.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        edumazet@google.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34326 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751175AbcJUL3y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 07:29:54 -0400
Received: by mail-pf0-f193.google.com with SMTP id 128so8452203pfz.1
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 04:29:53 -0700 (PDT)
In-Reply-To: <46dd208fee014c0837d750ffa13e625c6f4ee53c.1477043972.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-10-21 at 12:46 +0200, Daniel Borkmann wrote:
> Use case is mainly for soreuseport to select sockets for the local
> numa node, but since generic, lets also add this for other networking
> and tracing program types.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Daniel !
