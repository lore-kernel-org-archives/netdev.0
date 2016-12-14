From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: "virtio-net: enable multiqueue by default" in linux-next breaks
 networking on GCE
Date: Wed, 14 Dec 2016 11:42:16 -0500
Message-ID: <20161214164216.aufnr6xekeiudein@thunk.org>
References: <20161212233343.q5xlv55rc5npqaqp@thunk.org>
 <bb997932-20d2-42f4-0f42-bd28ae151076@redhat.com>
 <20161213194431.42vtozn6bs24vwda@thunk.org>
 <95568017-e7b1-df95-ec49-f38ae8eb1b14@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, netdev@vger.kernel.org, mst@redhat.com,
        nhorman@tuxdriver.com, davem@davemloft.net
To: Wei Xu <wexu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:53446 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756112AbcLNQmV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Dec 2016 11:42:21 -0500
Content-Disposition: inline
In-Reply-To: <95568017-e7b1-df95-ec49-f38ae8eb1b14@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 14, 2016 at 12:24:43PM +0800, Wei Xu wrote:
> 
> BTW, although this is a guest issue, is there anyway to view the GCE
> host kernel or qemu(if it is) version?

No, there isn't, as far as I know.

    	  	    	     - Ted
