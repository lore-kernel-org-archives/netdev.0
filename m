From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NET: Mark snmp4_icmp_list[] as being unused
Date: Fri, 26 Oct 2007 00:05:13 +0100
Message-ID: <23686.1193353513@redhat.com>
References: <OFC35175B6.40DF81DF-ON8825737F.00799984-8825737F.0079C01A@us.ibm.com>
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44870 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754005AbXJYXGV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 19:06:21 -0400
In-Reply-To: <OFC35175B6.40DF81DF-ON8825737F.00799984-8825737F.0079C01A@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens <dlstevens@us.ibm.com> wrote:

> What about just removing it, or do you think it's
> useful for documentation of the order? Either way,

I don't know whether it's intended to be used for something, perhaps a
debugging macro.  Perhaps it should be #if'd out instead.

David
