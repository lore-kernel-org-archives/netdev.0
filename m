From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: net-next virtio_net merge...
Date: Wed, 2 Aug 2017 16:14:54 +0300
Message-ID: <20170802161436-mutt-send-email-mst@kernel.org>
References: <20170801.151220.241719275238287015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jasowang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54162 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751197AbdHBNPZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Aug 2017 09:15:25 -0400
Content-Disposition: inline
In-Reply-To: <20170801.151220.241719275238287015.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 01, 2017 at 03:12:20PM -0700, David Miller wrote:
> 
> I just merged net into net-next and one of the conflicts had to do with
> the truesize bug fix in 'net' conflicting with the changes in 'net-next'
> which encode the headroom into the contexts for mergeable buffers.
> 
> I did my best to resolve this, but if you two would take a closer
> look and test out the result I would really appreciate it!
> 
> Thanks.

Looks good to me. Will test later today or tomorrow.

-- 
MST
