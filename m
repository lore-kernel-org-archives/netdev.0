From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next V2 1/2] pktgen: Specify num packets per thread
Date: Thu, 15 Jun 2017 21:21:52 +0200
Message-ID: <20170615212152.690bbfdf@redhat.com>
References: <1497542842-13721-1-git-send-email-tariqt@mellanox.com>
        <1497542842-13721-2-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>, brouer@redhat.com
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59994 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750814AbdFOTV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 15:21:58 -0400
In-Reply-To: <1497542842-13721-2-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jun 2017 19:07:21 +0300
Tariq Toukan <tariqt@mellanox.com> wrote:

> Use -n <num>, to specify the number of packets every
> thread sends.
> Zero means indefinitely.
> 
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
