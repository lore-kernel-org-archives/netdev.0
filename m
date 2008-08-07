From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: reduce memory footprint of sctp_chunk structure
Date: Thu, 7 Aug 2008 15:53:15 -0400
Message-ID: <20080807195315.GA12886@hmsendeavour.rdu.redhat.com>
References: <20080725121130.GB12725@hmsreliant.think-freely.org> <4889CF25.30405@hp.com> <20080725164409.GD12725@hmsreliant.think-freely.org> <489B49B5.7090708@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2419 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752579AbYHGTxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 15:53:22 -0400
Content-Disposition: inline
In-Reply-To: <489B49B5.7090708@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 07, 2008 at 03:15:01PM -0400, Vlad Yasevich wrote:
> Hi Neil
> 
> A few problem I found once I started testing with the new fast
> retransmit regression test I just wrote.
> > 


Cool, thanks for the heads up!

-- 
/***************************************************
 *Neil Horman
 *nhorman@tuxdriver.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
