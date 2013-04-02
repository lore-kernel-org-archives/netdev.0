From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next PATCH] net: fix smatch warnings inside datagram_poll
Date: Tue, 2 Apr 2013 20:46:32 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5855B0E482@ORSMSX105.amr.corp.intel.com>
References: <20130402203414.24602.6059.stgit@jekeller-hub.jf.intel.com>
 <20130402.164025.2237059970586581339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:5131 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762230Ab3DBUqe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 16:46:34 -0400
In-Reply-To: <20130402.164025.2237059970586581339.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> Sent: Tuesday, April 02, 2013 1:40 PM
> To: Keller, Jacob E
> Cc: netdev@vger.kernel.org
> Subject: Re: [net-next PATCH] net: fix smatch warnings inside
> datagram_poll
> 
> From: Jacob Keller <jacob.e.keller@intel.com>
> Date: Tue,  2 Apr 2013 13:34:15 -0700
> 
> > The code for commit 1218a2a1d233fd604a41e584163ec291418f8ea8
> actually turns out
> > to be incorrect.
> 
> This commit object SHA ID is not correct, it should be
> 7d4c04fc170087119727119074e72445f2bb192b.
> 
> Also, when referencing commits, always follow the SHA ID with the
> commit
> log message header line, enclosed in both parenthesis and double
> quotes.

Ok sorry about that. I will resend with correct format. Not sure how I had wrong commit ID.

Thanks

- Jake
 
