From: maximilian attems <max@stro.at>
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Sat, 22 Sep 2007 02:02:30 +0200
Message-ID: <20070922000230.GF19918@baikonur.stro.at>
References: <200709211201.24475.vda.linux@googlemail.com> <200709211905.23946.vda.linux@googlemail.com> <15775.1190399812@turing-police.cc.vt.edu> <200709212018.06553.vda.linux@googlemail.com> <20070921220333.3b31afb5@the-village.bc.nu> <46F446C3.9050600@garzik.org> <20070921234805.478efe15@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Denys Vlasenko <vda.linux@googlemail.com>,
	Valdis.Kletnieks@vt.edu, David Miller <davem@davemloft.net>,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:4776 "EHLO baikonur.stro.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544AbXIVACe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 20:02:34 -0400
Content-Disposition: inline
In-Reply-To: <20070921234805.478efe15@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 21, 2007 at 11:48:05PM +0100, Alan Cox wrote:
> > According to an earlier thread, dgrs was never really maintained, 
> > written for hardware that was never really distributed widely, and very 
> > likely hasn't had users in years... if ever.
> > 
> > If that picture is accurate (it's a story I was told), then I am 
> > definitely queueing up a deletion patch.
> 
> I think thats sensible. If someone whines it can be put back but I really
> don't think anyone will

nobody did yet, please yell if you need a rebased patch.

-- 
maks
