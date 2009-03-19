From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Thu, 19 Mar 2009 16:04:44 -0700
Message-ID: <1237503884.16140.23.camel@HP1>
References: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.org>,
	"Bastian Blank" <waldi@debian.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ben Hutchings" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2359 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753228AbZCSXKB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2009 19:10:01 -0400
In-Reply-To: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2009-03-19 at 15:29 -0700, Ben Hutchings wrote:
> Based on a patch for Debian by Bastian Blank <waldi@debian.org>.
> 
> This patch contains the code changes for review, but should not be
> applied.  The complete patch, which is about 1 MB in size and therefore
> too large for the mailing list, is at:
> <http://womble.decadent.org.uk/tmp/0001-bnx2-Use-request_firmware.patch>.
> 


Thanks Ben and Bastian.  I will review this and test it out.  I think I
will add some logic to check firmware versions to guarantee some level
of compatibility.



