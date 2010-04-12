From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: add option to build m_xt as a tc module (v3)
Date: Mon, 12 Apr 2010 11:41:52 -0700
Message-ID: <20100412114152.57f0721d@nehalam>
References: <20100412115538.GA28338@amd64.fatal.se>
	<20100412083317.0d9e9f3f@nehalam>
	<20100412181359.GA4612@amd64.fatal.se>
	<20100412181943.GB4612@amd64.fatal.se>
	<20100412182423.GA5253@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59534 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752761Ab0DLSly (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 14:41:54 -0400
In-Reply-To: <20100412182423.GA5253@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Apr 2010 20:24:23 +0200
Andreas Henriksson <andreas@fatal.se> wrote:

> This will build the xt module (action ipt) of tc as a
> shared object that is linked at runtime by tc if used,
> rather then built into tc.
> 
> This is similar to how the atm qdisc support
> is handled (q_atm.so).
> 
> Signed-off-by: Andreas Henriksson <andreas@xxxxxxxx>

Applied thanks.

-- 
