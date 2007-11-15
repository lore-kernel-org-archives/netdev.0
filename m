From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3: strange errors and non-working-ness
Date: Thu, 15 Nov 2007 12:23:20 -0800
Message-ID: <1195158200.6360.17.camel@dell>
References: <20071115094728.GB2366@ff.dom.local>
 <1195154603.6360.9.camel@dell>
 <cccedfc60711151117v70b285fbl79bbc92ced176d54@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>,
	"netdev" <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: "Jon Nelson" <jnelson@jamponi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1442 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751746AbXKOTko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 14:40:44 -0500
In-Reply-To: <cccedfc60711151117v70b285fbl79bbc92ced176d54@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-11-15 at 13:17 -0600, Jon Nelson wrote:

> Is this what you mean? I pulled this from the quoted text:
> 
> Nov 10 22:45:52 frank kernel: NETDEV WATCHDOG: eth0: transmit timed out
> 

Right.  This explains the reset at 22:45:52, but not the earlier reset
at 22:24:40.  Link never came up after that earlier reset.

Is this a new problem introduced by a new driver?  I notice you are
using tg3 3.65.  Have you used newer versions or older versions?

