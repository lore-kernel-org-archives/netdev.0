From: David Miller <davem@davemloft.net>
Subject: Re: depending on IPv6 symbols
Date: Tue, 06 Feb 2007 15:33:02 -0800 (PST)
Message-ID: <20070206.153302.41699956.davem@davemloft.net>
References: <adaodo6sy9o.fsf_-_@cisco.com>
	<20070206.144939.118629871.davem@davemloft.net>
	<adad54msxrt.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, miika@iki.fi, Diego.Beltrami@hiit.fi,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, mst@mellanox.co.il
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58970
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965038AbXBFXd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 18:33:28 -0500
In-Reply-To: <adad54msxrt.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 06 Feb 2007 14:53:58 -0800

> Would you like a patch to do the same thing for INET_IPGRE (and fix
> the #ifdefs in ip_gre.c)?

Sure, although I'm surprised nobody noticed that build failure
before :-)
