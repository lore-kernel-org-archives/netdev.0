From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Lksctp-developers] [2.6 patch] make sctp_addto_param() static
Date: Mon, 10 Sep 2007 09:42:25 -0400
Message-ID: <20070910134225.GC14606@hmsendeavour.rdu.redhat.com>
References: <20070909202550.GX3563@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>, sri@us.ibm.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2617 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755889AbXIJNoy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 09:44:54 -0400
Content-Disposition: inline
In-Reply-To: <20070909202550.GX3563@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 09, 2007 at 10:25:50PM +0200, Adrian Bunk wrote:
> sctp_addto_param() can become static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
ACK, seems reasonable to me.
Neil


-- 
/***************************************************
 *Neil Horman
 *nhorman@tuxdriver.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
