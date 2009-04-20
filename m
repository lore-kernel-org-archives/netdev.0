From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 1/8] tg3: Fix SEEPROM accesses
Date: Mon, 20 Apr 2009 15:02:10 -0700
Message-ID: <20090420220210.GB7358@xw6200.broadcom.net>
References: <1240247953.7009@xw6200>
 <20090420.145328.227301985.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3216 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753924AbZDTWB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 18:01:57 -0400
In-Reply-To: <20090420.145328.227301985.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 20, 2009 at 02:53:28PM -0700, David Miller wrote:
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Mon, 20 Apr 2009 09:52:49 -0700
> 
> > The recent NVRAM patches sanitized how the driver deals with NVRAM
> > data, but they failed to bring the SEEPROM interfaces inline with
> > the new strategy.  This patch brings the SEEPROM interfaces up to date.
> > This patch also reverts commit 0d489ffb76de0fe804cf06a9d4d11fa7342d74b9.
> > 
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > Tested-by: Robin Holt <holt@sgi.com>
> > Tested-by: James Bottomley <james.bottomley@HansenPartnership.com>
> 
> Applied, thanks.
> 
> But please provide a text string header line from the commit message
> of commits you reference by SHA1 ID, I think I've told you guys to
> do this more than once.

Yes.  I forgot about that.  My apologies.

