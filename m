From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH][BNX2]: Disable MSI on 5706 if AMD 8132 bridge is
 present
Date: Fri, 29 Sep 2006 16:27:35 -0700
Message-ID: <1159572456.3741.38.camel@rh4>
References: <1159565963.3741.23.camel@rh4>
 <20060929.154917.125894679.davem@davemloft.net>
 <451DA57F.60609@garzik.org>
 <20060929.160807.28788865.davem@davemloft.net>
 <451DA902.7030409@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:267 "EHLO mms2.broadcom.com")
	by vger.kernel.org with ESMTP id S1422646AbWI2XbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 19:31:16 -0400
To: "Jeff Garzik" <jeff@garzik.org>
In-Reply-To: <451DA902.7030409@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-09-29 at 19:15 -0400, Jeff Garzik wrote:

> It was completely vague as to why this incompatibility was specific to 
> the 5706, when -- as the description noted -- the behavior is legal.
> 

The description is a bit vague in that one aspect that Jeff pointed out,
but otherwise very complete in my opinion.

> Re-read the patch.  At no time does it say 5706 was in the wrong.
> 

The behavior is legal but AMD believes that it is unique to the 5706.  I
cannot make this less vague since it is a recommendation from AMD.  I
just trust their opinion on this.


