From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [PATCH] sctp compilation failed due to lack of
 sctp_local_addr_free
Date: Thu, 26 May 2011 11:40:34 -0700
Message-ID: <837A992BD1360242AE0C50C6BCB069C18415C8@orsmsx003.amr.corp.intel.com>
References: <1306427323.7510.2.camel@lb-tlvb-dmitry>
 <20110526.133929.1471692552076759601.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"difrost.kernel@gmail.com" <difrost.kernel@gmail.com>
To: David Miller <davem@davemloft.net>,
	"dmitry@broadcom.com" <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20191 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932148Ab1EZSkg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 14:40:36 -0400
In-Reply-To: <20110526.133929.1471692552076759601.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of David Miller
>Sent: Thursday, May 26, 2011 10:39 AM
>To: dmitry@broadcom.com
>Cc: netdev@vger.kernel.org; difrost.kernel@gmail.com
>Subject: Re: [PATCH] sctp compilation failed due to lack of sctp_local_addr_free
>
>
>This has been fixed for days.

Fixed in net-2.6, yes, but not yet in net-next-2.6
