From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1]ixgbe: Driver for Intel 82598 based 10GbE PCI Express
 family of adapters
Date: Fri, 27 Jul 2007 16:01:08 -0400
Message-ID: <46AA4F04.8070902@garzik.org>
References: <E35F4F4D7F6C9E4E826FEC1F86CEF58304487242@orsmsx412.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, arjan@linux.intel.com,
	akpm@linux-foundation.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hch@infradead.org,
	nhorman@tuxdriver.com, inaky@linux.intel.com, mb@bu3sch.de,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60677 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764954AbXG0UBQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2007 16:01:16 -0400
In-Reply-To: <E35F4F4D7F6C9E4E826FEC1F86CEF58304487242@orsmsx412.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Veeraiyan, Ayyappan wrote:
> So, with driver/device supporting multiple Tx and Rx queues, I think, it
> would be very useful to have ethtool interface to manage the number of
> Tx and Rx queues of the interface.


Absolutely!  ethtool patches welcome :)

git://git.kernel.org/pub/scm/network/ethtool/ethtool.git

	Jeff


