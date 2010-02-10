From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 1/1 net-next] virtio_net: remove send queue
Date: Wed, 10 Feb 2010 08:54:30 -0800
Message-ID: <1265820870.23239.1.camel@localhost.localdomain>
References: <1265674482.4484.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org, rusty@rustcorp.com.au,
	mst@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:54699 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753672Ab0BJQyf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 11:54:35 -0500
In-Reply-To: <1265674482.4484.10.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netperf results showed about 20% transmission gain with this patch for
virtio_net.

Thanks
Shirley

