From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/6] [BNX2]: Pre-initialize struct cpu_reg.
Date: Fri, 16 May 2008 14:00:08 -0700 (PDT)
Message-ID: <20080516.140008.41189480.davem@davemloft.net>
References: <1210973448.5507.21.camel@dell>
	<20080516.133000.09573615.davem@davemloft.net>
	<1210974796.5938.1.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51764
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755581AbYEPVAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 17:00:13 -0400
In-Reply-To: <1210974796.5938.1.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 16 May 2008 14:53:16 -0700

> On Fri, 2008-05-16 at 13:30 -0700, David Miller wrote:
> > From: "Michael Chan" <mchan@broadcom.com>
> > Date: Fri, 16 May 2008 14:30:48 -0700
> > 
> > > [BNX2]: Pre-initialize struct cpu_reg.
> > 
> > Hmmm, I'm missing patches 1, 2, and 6.  Perhaps they are
> > stuck in a mail queue somewhere?
> > 
> 
> All patches made it to netdev.  If you are still missing them, I'll
> forward to you again separately.

I did end up getting them all, thanks.

The only thing that needs fixing is the addition of the
necessary parenthesis around the expression defined by
the BNX2_RX_OFFSET macro, as noticed by Ben Hutchings.

Please fix that up, thanks!
