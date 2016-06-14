From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v8 1/5] ptr_ring: array based FIFO for pointers
Date: Tue, 14 Jun 2016 14:02:42 +0200
Message-ID: <20160614140242.47e2ccd7@redhat.com>
References: <1465851234-13558-1-git-send-email-mst@redhat.com>
	<20160613235431-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	kvm@vger.kernel.org, brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27278 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140AbcFNMCx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 08:02:53 -0400
In-Reply-To: <20160613235431-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Jun 2016 23:54:31 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> A simple array based FIFO of pointers.  Intended for net stack which
> commonly has a single consumer/producer.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
