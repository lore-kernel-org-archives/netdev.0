From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 1/2] pktgen: Specify num packets per thread
Date: Wed, 14 Jun 2017 09:26:15 +0200
Message-ID: <20170614092615.6701334d@redhat.com>
References: <1497366289-22255-1-git-send-email-tariqt@mellanox.com>
        <1497366289-22255-2-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>, brouer@redhat.com
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60104 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750751AbdFNH0V (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 03:26:21 -0400
In-Reply-To: <1497366289-22255-2-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Jun 2017 18:04:48 +0300
Tariq Toukan <tariqt@mellanox.com> wrote:

> Use -n <num>, to specify the number of packets every
> thread sends.
> Zero means indefinitely.
> 
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>

Patch 1/2 looks good to me (have some comments on patch 2/2)

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
