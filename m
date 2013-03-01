From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: e1000e failed to check map error
Date: Fri, 1 Mar 2013 17:13:29 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A1844D022AE1@ORSMSX102.amr.corp.intel.com>
References: <20130301053007.GA14474@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Dave Jones <davej@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12891 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886Ab3CARNc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 12:13:32 -0500
In-Reply-To: <20130301053007.GA14474@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Dave Jones
> Sent: Thursday, February 28, 2013 9:30 PM
> To: netdev@vger.kernel.org
> Subject: e1000e failed to check map error
> 
> Linus' current tree shows this shortly after boot for me..
> 
> WARNING: at lib/dma-debug.c:933 check_unmap+0x407/0x8a0()

Thanks for the report Dave.  I'll look into it.

Bruce.
