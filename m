From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-next 0/11] tg3: 5719, VLAN, and EEE bugfixes
Date: Wed, 26 Jan 2011 12:01:24 -0800
Message-ID: <20110126200124.GB24987@mcarlson.broadcom.com>
References: <1296007137-23146-1-git-send-email-mcarlson@broadcom.com>
 <20110125.193859.193720518.davem@davemloft.net>
 <1296022477.2633.16.camel@edumazet-laptop>
 <20110125.222734.189693738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4597 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753725Ab1AZUBj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 15:01:39 -0500
In-Reply-To: <20110125.222734.189693738.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 25, 2011 at 10:27:34PM -0800, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 26 Jan 2011 07:14:37 +0100
> 
> > I tested the vlan patch on my machine, and it solves the problem I had
> > with linux-2.6
> > 
> > I believe this particular patch should be net-2.6 material, not
> > net-next-2.6
> 
> Agreed.
> 
> > (There is a small rejected hunk)
> 
> Matt, if you would send me a net-2.6 backport with your blessing
> I'd appreciate it.

Sure.  Coming right up.

