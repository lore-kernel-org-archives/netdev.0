From: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Subject: RE: [PATCH 1/1]ixgbe: Driver for Intel 82598 based 10GbE PCI Express family of adapters
Date: Fri, 27 Jul 2007 13:06:48 -0700
Message-ID: <E35F4F4D7F6C9E4E826FEC1F86CEF58304487278@orsmsx412.amr.corp.intel.com>
References: <46AA4F04.8070902@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>, <arjan@linux.intel.com>,
	<akpm@linux-foundation.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hch@infradead.org>,
	<nhorman@tuxdriver.com>, <inaky@linux.intel.com>, <mb@bu3sch.de>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34761 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934134AbXG0UGv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 16:06:51 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46AA4F04.8070902@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Jeff Garzik [mailto:jeff@garzik.org]
>Veeraiyan, Ayyappan wrote:
>> So, with driver/device supporting multiple Tx and Rx queues, I think,
it
>> would be very useful to have ethtool interface to manage the number
of
>> Tx and Rx queues of the interface.
>
>
>Absolutely!  ethtool patches welcome :)
>
>git://git.kernel.org/pub/scm/network/ethtool/ethtool.git
>

We discussed this here today and we will try to come up with patches.

Also, FWIW, I will be offline for next 2 months, and someone (Auke ? :))
from our team will submit updated driver shortly..

Ayyappan
