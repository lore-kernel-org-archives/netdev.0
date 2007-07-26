From: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Subject: RE: [PATCH 0/1] ixgbe: Support for Intel(R) 10GbE PCI Express	adapters -	Take #2
Date: Thu, 26 Jul 2007 13:07:53 -0700
Message-ID: <E35F4F4D7F6C9E4E826FEC1F86CEF583044867F4@orsmsx412.amr.corp.intel.com>
References: <46A4F8F6.3010008@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jeff Garzik" <jeff@garzik.org>, <netdev@vger.kernel.org>,
	<arjan@linux.intel.com>, <akpm@linux-foundation.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hch@infradead.org>,
	<shemminger@linux-foundation.org>, <nhorman@tuxdriver.com>,
	<inaky@linux.intel.com>, <mb@bu3sch.de>
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:15753 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935356AbXGZUID convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 16:08:03 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46A4F8F6.3010008@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/23/07, Rick Jones <rick.jones2@hp.com> wrote:
>
>The bidirectional looks like a two concurrent stream (TCP_STREAM +
>TCP_MAERTS)
>test right?
>
>If you want a single-stream bidirectional test, then with the top of
trunk
>netperf you can use:
>

Thanks for the feedback Rick. We haven't used the netperf trunk. The
person who actually got these numbers will be trying the netperf trunk
little later and we will post the results..
