From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 0/1] ixgbe: Support for Intel(R) 10GbE PCI	Express	adapters
 -	Take #2
Date: Thu, 26 Jul 2007 13:20:24 -0700
Message-ID: <46A90208.4040906@hp.com>
References: <E35F4F4D7F6C9E4E826FEC1F86CEF583044867F4@orsmsx412.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	arjan@linux.intel.com, akpm@linux-foundation.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hch@infradead.org,
	shemminger@linux-foundation.org, nhorman@tuxdriver.com,
	inaky@linux.intel.com, mb@bu3sch.de
To: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:36269 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934243AbXGZUVp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 16:21:45 -0400
In-Reply-To: <E35F4F4D7F6C9E4E826FEC1F86CEF583044867F4@orsmsx412.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Thanks for the feedback Rick. We haven't used the netperf trunk. The
> person who actually got these numbers will be trying the netperf trunk
> little later and we will post the results..

Just in case someone has top-of-trunk worries, the basic single-stream, 
bidirectional stuff is in the 2.4.3 released bits.  It is the "user friendly" 
netperf-does-the-math bit that is top of trunk :)

rick

