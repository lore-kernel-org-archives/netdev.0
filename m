From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [V2 PATCH net-next 5/5] xdp: get tracepoints xdp_exception and
 xdp_redirect in sync
Date: Wed, 23 Aug 2017 12:59:50 +0200
Message-ID: <599D6026.1000901@iogearbox.net>
References: <150348327373.23476.14851572406177222309.stgit@firesoul> <150348334039.23476.16866879022276856834.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40340 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753824AbdHWK7v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 06:59:51 -0400
In-Reply-To: <150348334039.23476.16866879022276856834.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2017 12:15 PM, Jesper Dangaard Brouer wrote:
> Remove the net_device string name from the xdp_exception tracepoint,
> like the xdp_redirect tracepoint.
>
> Align the TP_STRUCT to have common entries between these two
> tracepoint.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
