From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: softmac mtu
Date: Mon, 25 Sep 2006 16:01:32 -0400
Message-ID: <20060925200125.GF16949@tuxdriver.com>
References: <ef3s4u$or5$3@sea.gmane.org> <ef9a0b$4jb$4@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:55312 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750782AbWIYUBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 16:01:47 -0400
To: Matthieu CASTET <castet.matthieu@free.fr>
Content-Disposition: inline
In-Reply-To: <ef9a0b$4jb$4@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 25, 2006 at 07:17:31PM +0000, Matthieu CASTET wrote:
> So why a special mtu handler is not implemented in 802.11 stack :
> - 802.11 stack doesn't support bigger packet
> - 802.11 stack doesn't support very bigger packet (with
> 802.11 fragmentation)
> - 802.11 writers were lazy

I suspect the latter...patches welcome! :-)

-- 
John W. Linville
linville@tuxdriver.com
