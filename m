From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/3] driver/net/*: remove redundant argument comments
Date: Sat, 22 Nov 2008 11:40:14 +0000
Message-ID: <20081122114014.379f2762@lxorguk.ukuu.org.uk>
References: <4927b790.0e0d6e0a.65cc.ffffcb05@mx.google.com>
	<9929d2390811212355j635e0e8iee0e53678efc5f09@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Qinghuang Feng" <qhfeng.kernel@gmail.com>,
	"David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:36078 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758116AbYKVLmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 06:42:09 -0500
In-Reply-To: <9929d2390811212355j635e0e8iee0e53678efc5f09@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > - * @rx_ring: pointer to receive ring structure
> >  * @cleaned_count: number of buffers to allocate this pass
> >  **/
> >
> 
> NAK - rather than removing documentation, I would suggest improving
> the documentation.  

I would suggest reading the patch more carefully - there is no rx_ring
argument. The documentation in the header is stale.

