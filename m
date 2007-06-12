From: Jason Lunz <lunz@falooley.org>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 18:17:57 -0400
Message-ID: <20070612221756.GC27363@metaxa.reflex>
References: <466F0D78.7090404@candelatech.com> <20070612.142658.45082832.davem@davemloft.net> <20070612214753.GB27363@metaxa.reflex> <20070612.145534.128867899.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, jeff@garzik.org, netdev@vger.kernel.org,
	kaber@trash.net, hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crown.reflexsecurity.com ([72.54.139.163]:44685 "EHLO
	crown.reflexsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492AbXFLWSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 18:18:03 -0400
Content-Disposition: inline
In-Reply-To: <20070612.145534.128867899.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 12, 2007 at 02:55:34PM -0700, David Miller wrote:
> These chips allow this too, Microsoft defined a standard for
> RX queue interrupt hashing by flow so everyone puts it, or
> something like it, in hardware.

I think you're referring to "RSS"?

http://www.microsoft.com/whdc/device/network/NDIS_RSS.mspx
http://msdn2.microsoft.com/en-us/library/ms795609.aspx

Jason
