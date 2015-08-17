From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 1/2] net: declare new net_device priv_flag IFF_NO_QUEUE
Date: Mon, 17 Aug 2015 08:52:36 +0200
Message-ID: <20150817085236.0092b08d@redhat.com>
References: <1439485268-20953-1-git-send-email-phil@nwl.cc>
	<1439485268-20953-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52773 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752584AbbHQGwi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 02:52:38 -0400
In-Reply-To: <1439485268-20953-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Aug 2015 19:01:06 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This private net_device flag can be set by drivers to inform that a
> device runs fine without a qdisc attached. This was formerly done by
> setting tx_queue_len to zero.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
