From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 4/4] bpf: allow access to skb->len from offloads
Date: Tue, 17 Oct 2017 11:38:38 +0200
Message-ID: <59E5CF9E.8030300@iogearbox.net>
References: <20171016234056.1964-1-jakub.kicinski@netronome.com> <20171016234056.1964-5-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41354 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754622AbdJQJik (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 05:38:40 -0400
In-Reply-To: <20171016234056.1964-5-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2017 01:40 AM, Jakub Kicinski wrote:
> Since we are now doing strict checking of what offloads
> may access, make sure skb->len is on that list.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
