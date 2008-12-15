From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: bnx2x machine check in bnx2x_ack_int()
Date: Mon, 15 Dec 2008 21:36:34 +0200
Message-ID: <1229369794.26330.2.camel@lb-tlvb-eliezer>
References: <200812091204.35296.bjorn.helgaas@hp.com>
 <200812150921.08668.bjorn.helgaas@hp.com>
 <1229361480.22295.22.camel@lb-tlvb-eliezer>
 <200812151104.00724.bjorn.helgaas@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Bjorn Helgaas" <bjorn.helgaas@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1792 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751971AbYLOTi1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2008 14:38:27 -0500
In-Reply-To: <200812151104.00724.bjorn.helgaas@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-12-15 at 10:04 -0800, Bjorn Helgaas wrote:
> Yep, it's definitely possible that this is HW related.  The proto
> has 57710, but the product will ultimately use the 57711, so I don't
> really even care about testing the 57710.
> 
> After upgrading some pieces on my boards, I can't reproduce the
> MCA either.  So I guess we can just write it off for now.  The only
> reason I pointed out the issue at all is because it really hampered
> testing of standard distro bits on the rest of the box.

Please let me know if you see this issue again - we can try to
root-cause it. And again, sorry for the late initial response.

Eilon


