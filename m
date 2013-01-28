From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [PATCH] checkpatch.pl: Fix warnings on code comments
Date: Mon, 28 Jan 2013 17:17:27 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A1843ABC3058@ORSMSX102.amr.corp.intel.com>
References: <1359286539-18395-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<20130127.185910.1743425400733006443.davem@davemloft.net>
	<1359341805.2255.56.camel@jtkirshe-mobl>
 <20130127.220728.634216960903942581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "apw@canonical.com" <apw@canonical.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53370 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756247Ab3A1RR3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 12:17:29 -0500
In-Reply-To: <20130127.220728.634216960903942581.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> Sent: Sunday, January 27, 2013 7:07 PM
> To: Kirsher, Jeffrey T
> Cc: apw@canonical.com; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org
> Subject: Re: [PATCH] checkpatch.pl: Fix warnings on code comments
> 
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sun, 27 Jan 2013 18:56:45 -0800
> 
> > So will you be fine with cleanup patches which go through and
> > convert all the existing code comments to the desired format?
> 
> Sure.

Not all Intel drivers...e1000e already conforms to the comment style :-)

Bruce.
