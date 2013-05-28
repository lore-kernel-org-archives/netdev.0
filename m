From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [PATCH net-next 0/4] igb: auxiliary PHC functions for the i210.
Date: Tue, 28 May 2013 15:58:50 +0000
Message-ID: <CDCA2229.1E896%matthew.vick@intel.com>
References: <cover.1369645944.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:13458 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934550Ab3E1P6x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 11:58:53 -0400
In-Reply-To: <cover.1369645944.git.richardcochran@gmail.com>
Content-Language: en-US
Content-ID: <EDD4E5A906F5E246865A6D30907DD7E7@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/27/13 2:21 AM, "Richard Cochran" <richardcochran@gmail.com> wrote:

>This patch series adds three features: time stamping external events,
>producing a periodic output signal, and an internal PPS event. The
>i210 PCIe card has a 6 pin header with SDP0 and SDP1, making it easy
>to try out this new functionality.
>
>Thanks,
>Richard

I have some questions about this series, but thanks for doing this work,
Richard!

Cheers,
Matthew

Matthew Vick
Linux Development
Networking Division
Intel Corporation
