From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH net-next 0/2] Defer skb allocation in virtio_net recv
Date: Thu, 17 Dec 2009 23:57:30 -0800
Message-ID: <1261123050.4148.28.camel@localhost.localdomain>
References: <1261122090.4148.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:53935 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbZLRH5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 02:57:36 -0500
In-Reply-To: <1261122090.4148.24.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Send skb queue can also be reduced with detach_unused_buf API by it is
not a part of this patch.

Shirley

