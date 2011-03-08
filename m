From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Tue, 08 Mar 2011 13:57:24 -0800
Message-ID: <1299621444.25664.77.camel@localhost.localdomain>
References: <20110127.130240.104065182.davem@davemloft.net>
	 <OF5CFD7B6A.4CBE4E3B-ON6525782B.0014DC5B-6525782B.001979CB@in.ibm.com>
	 <20110202044222.GC3818@redhat.com>
	 <201102091107.20270.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:45665 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751261Ab1CHV52 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 16:57:28 -0500
In-Reply-To: <201102091107.20270.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-02-09 at 11:07 +1030, Rusty Russell wrote:
> I've finally read this thread... I think we need to get more serious
> with our stats gathering to diagnose these kind of performance issues.
> 
> This is a start; it should tell us what is actually happening to the
> virtio ring(s) without significant performance impact... 

Should we also add similar stat on vhost vq as well for monitoring
vhost_signal & vhost_notify?

Shirley

