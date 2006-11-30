From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Wed, 29 Nov 2006 16:53:11 -0800 (PST)
Message-ID: <20061129.165311.45739865.davem@davemloft.net>
References: <HNEBLGGMEGLPMPPDOPMGCEAKCGAA.wenji@fnal.gov>
	<HNEBLGGMEGLPMPPDOPMGGEAKCGAA.wenji@fnal.gov>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48877
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S967754AbWK3AxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 19:53:08 -0500
To: wenji@fnal.gov
In-Reply-To: <HNEBLGGMEGLPMPPDOPMGGEAKCGAA.wenji@fnal.gov>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please, it is very difficult to review your work the way you have
submitted this patch as a set of 4 patches.  These patches have not
been split up "logically", but rather they have been split up "per
file" with the same exact changelog message in each patch posting.
This is very clumsy, and impossible to review, and wastes a lot of
mailing list bandwith.

We have an excellent file, called Documentation/SubmittingPatches, in
the kernel source tree, which explains exactly how to do this
correctly.

By splitting your patch into 4 patches, one for each file touched,
it is impossible to review your patch as a logical whole.

Please also provide your patch inline so people can just hit reply
in their mail reader client to quote your patch and comment on it.
This is impossible with the attachments you've used.

Thanks.
