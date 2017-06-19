From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC net-next 1/8] xdp: pass XDP flags into install handlers
Date: Tue, 20 Jun 2017 01:38:24 +0200
Message-ID: <59486070.3090001@iogearbox.net>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com> <20170616235746.16337-2-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kafai@fb.com, netoptimizer@brouer.com,
        oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:32895 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753028AbdFSXil (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 19:38:41 -0400
In-Reply-To: <20170616235746.16337-2-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2017 01:57 AM, Jakub Kicinski wrote:
> Pass XDP flags to the xdp ndo.  This will allow drivers to look
> at the mode flags and make decisions about offload.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
