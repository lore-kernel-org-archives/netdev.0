From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: reminder, 2.6.18 window...
Date: Thu, 25 May 2006 14:17:28 +0200
Message-ID: <20060525121728.GA18243@electric-eye.fr.zoreil.com>
References: <447412CA.50303@ipom.com> <4474A489.4080308@garzik.org> <20060524185644.GF22881@ipom.com> <4474AE92.3030501@garzik.org> <20060524191442.GG22881@ipom.com> <1148501433.5325.52.camel@jzny2> <20060524204800.GH22881@ipom.com> <4474CA66.5020401@hp.com> <4474CBAA.4040307@candelatech.com> <44753A3B.5010204@ipom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	Rick Jones <rick.jones2@hp.com>, jamal <hadi@cyberus.ca>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:51391 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S965080AbWEYMUl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 08:20:41 -0400
To: Phil Dibowitz <phil@ipom.com>
Content-Disposition: inline
In-Reply-To: <44753A3B.5010204@ipom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Phil Dibowitz <phil@ipom.com> :
[...]
> Right. I think the point here is that it does _NOT_ inherently break
> things. If you don't like the behavior, don't run "ethtool -z eth0",
> it's that simple.

It would be better to explain why several sysadmins want this feature
and why it can't be done in an hardware-independent way at the
application level.

-- 
Ueimor
