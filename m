From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 00/34]bnx2x: Bug fixes
Date: Thu, 15 Jan 2009 11:53:11 +0200
Message-ID: <1232013191.4971.10.camel@lb-tlvb-eliezer>
References: <1231951356.11301.121.camel@lb-tlvb-eliezer>
 <20090114.213622.242296202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pl@linux.vnet.ibm.com" <pl@linux.vnet.ibm.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3230 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761407AbZAOJyH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 04:54:07 -0500
In-Reply-To: <20090114.213622.242296202.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-14 at 21:36 -0800, David Miller wrote:

> I've gone through patches 1 to 17 for now.  Patched I didn't apply:
> 
> 1) [PATCH 02/34]bnx2x: Barriers for the compiler
> 
>    Need feedback on my query, if this requires a compiler barrier
>    it almost certainly needs cpu reordering barriers too.

I still believe it is in place, please see my response

> I'll go over the rest after I send what I have now to Linus, but don't
> set your expectations high, this is way too many patches to be sending
> now.

As long as it is in your queue, I still have hope...

Thanks,
Eilon


