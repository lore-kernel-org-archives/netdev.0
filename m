From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Mon, 24 Sep 2007 13:32:23 -0400
Message-ID: <20070924173223.GL5386@csclub.uwaterloo.ca>
References: <200709211201.24475.vda.linux@googlemail.com> <200709211905.23946.vda.linux@googlemail.com> <p73ps0b93ph.fsf@bingen.suse.de> <200709212337.53043.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, jeff@garzik.org,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:46450 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756798AbXIXRcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 13:32:24 -0400
Content-Disposition: inline
In-Reply-To: <200709212337.53043.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 21, 2007 at 11:37:52PM +0100, Denys Vlasenko wrote:
> But I compile net/* into bzImage. I like netbooting :)

Isn't it possible to netboot with an initramfs image?  I am pretty sure
I have seen some systems do exactly that.

--
Len Sorensen
