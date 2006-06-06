From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] LSM-IPsec SELinux Authorize (with minor fix)
Date: Mon, 05 Jun 2006 22:49:13 -0700 (PDT)
Message-ID: <20060605.224913.35664171.davem@davemloft.net>
References: <20060606043818.GA4125@jiayuguan.watson.ibm.com>
	<Pine.LNX.4.64.0606060133220.9787@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cxzhang@watson.ibm.com, netdev@vger.kernel.org, chrisw@osdl.org,
	herbert@gondor.apana.org.au, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu, latten@austin.ibm.com, sergeh@us.ibm.com,
	gcwilson@us.ibm.com, czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50852
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932072AbWFFFt0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 01:49:26 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0606060133220.9787@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Tue, 6 Jun 2006 01:37:04 -0400 (EDT)

> On Tue, 6 Jun 2006, Catherine Zhang wrote:
> 
> > Minor fix per James' comment.
> 
> Can you also add a Signed-off-by line?
> 
> I can't recall if you were the original author.   If not, we also need a 
> From line (per Documentation/SubmittingPatches).

I'll apply this to my net-2.6.18 tree once this is all sorted
out.  Thanks everyone.
