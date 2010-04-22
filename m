From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next PATCH 1/2] add iovnl netlink support
Date: Thu, 22 Apr 2010 13:12:46 +0200
Message-ID: <201004221312.46935.arnd@arndb.de>
References: <20100419191807.10423.84600.stgit@savbu-pc100.cisco.com> <201004221253.11290.arnd@arndb.de> <20100422.035615.176728799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: scofeldm@cisco.com, netdev@vger.kernel.org, chrisw@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:49867 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179Ab0DVLNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 07:13:08 -0400
In-Reply-To: <20100422.035615.176728799.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 22 April 2010, David Miller wrote:
> But reading other parts of the discussion it seems that
> IOV_ATTR_VF_IFNAME and some other bits will likely be
> removed in the initial implementation of this stuff.

That's what I suggested, yes. However, I'm still waiting for
a reply from Scott wether it's actually possibly to remove
it based on the way that the enic firmware works.

	Arnd
