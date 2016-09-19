From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH] mlx4: add missed recycle opportunity for
 XDP_TX on TX failure
Date: Mon, 19 Sep 2016 17:57:20 +0200
Message-ID: <20160919175720.59c33fca@redhat.com>
References: <20160919.013925.1660395475687226712.davem@davemloft.net>
        <20160919073957.32059.59156.stgit@firesoul>
        <1474295315.22679.85.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, tom@herbertland.com,
        bblanco@plumgrid.com, rana.shahot@gmail.com,
        "David S. Miller\" <davem@davemloft.net>, brouer@redhat.com"@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33558 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752225AbcISP5Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 11:57:25 -0400
In-Reply-To: <1474295315.22679.85.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Sep 2016 07:28:35 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > +			xdp_drop:  
> 
> A label should start at the beginning of the line (ie : not indented)

Understood, send a V2

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
