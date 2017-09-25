From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 0/7] nfp: flower vxlan tunnel offload
Date: Mon, 25 Sep 2017 13:00:50 +0200
Message-ID: <20170925130050.62b99989@cakuba>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:50221 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934668AbdIYLA4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 07:00:56 -0400
Received: by mail-wm0-f50.google.com with SMTP id b195so18248008wmb.5
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 04:00:56 -0700 (PDT)
In-Reply-To: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Sep 2017 12:23:34 +0200, Simon Horman wrote:
> From: Simon Horman <simon.horman@netronome.com>
> 
> John says:
> 
> This patch set allows offloading of TC flower match and set tunnel fields
> to the NFP. The initial focus is on VXLAN traffic. Due to the current
> state of the NFP firmware, only VXLAN traffic on well known port 4789 is
> handled. The match and action fields must explicity set this value to be
> supported. Tunnel end point information is also offloaded to the NFP for
> both encapsulation and decapsulation. The NFP expects 3 separate data sets
> to be supplied.
...

Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>
