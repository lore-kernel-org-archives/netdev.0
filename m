From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 2/9] bnx2x: annotate struct eth_tx_db_data
Date: Thu, 22 Jan 2009 19:49:38 +0200
Message-ID: <1232646578.29087.85.camel@lb-tlvb-eliezer>
References: <1232517047.9701.20.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: "Harvey Harrison" <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3279 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760142AbZAVRuq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 12:50:46 -0500
In-Reply-To: <1232517047.9701.20.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-20 at 21:50 -0800, Harvey Harrison wrote:
> Always treated as little-endian values, annotate as such, use
> the leXX_add_cpu helpers rather than opencoded byteswapping.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

The next few patches are similar, and I feel more comfortable combining
them. I will try to follow your lead and will work on a suggestion that
will complete this task in the next couple of days. I rather not to
submit it half-backed.

Thanks,
Eilon


