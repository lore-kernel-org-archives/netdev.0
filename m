From: jamal <hadi@cyberus.ca>
Subject: Re: [Bonding-devel] Re: [PATCH 2.6] e100: use NAPI mode all the
	time
Date: 07 Jun 2004 07:17:58 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086607077.1590.267.camel@jzny.localdomain>
References: <200406070639.i576drvF026556@death.nxdomain.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Tim Mattox <tmattox@engr.uky.edu>,
        sfeldma@pobox.com, netdev@oss.sgi.com,
        bonding-devel@lists.sourceforge.net,
        Scott Feldman <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200406070639.i576drvF026556@death.nxdomain.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, 

dont have time to go through all that thread, but lets understand your
problem and setup. Lets start with the setup:
You have 4 ethx ports on PC1 x-connected to 4 on PC2. You have bonding
on PC1 but not on PC2. You have NAPI on both PC1 and PC2. Is any of them
multiprocessor?

Lets get the setup then we can continue the discussion.

cheers,
jamal
