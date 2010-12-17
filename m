From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [PATCH] e1000e: workaround missing power down mii control bit
 on 82571
Date: Fri, 17 Dec 2010 07:53:08 -0800
Message-ID: <8DD2590731AB5D4C9DBF71A877482A9001773F7BFC@orsmsx509.amr.corp.intel.com>
References: <20101216182847.GA14985@ajones-laptop.nbttech.com>
 <1292525797.3253.8.camel@bwh-desktop>
 <8DD2590731AB5D4C9DBF71A877482A9001773F7655@orsmsx509.amr.corp.intel.com>
 <8DD2590731AB5D4C9DBF71A877482A9001773F76C4@orsmsx509.amr.corp.intel.com>
 <20101216200425.GO18990@ajones-laptop.nbttech.com>
 <20101216221421.GR18990@ajones-laptop.nbttech.com>
 <8DD2590731AB5D4C9DBF71A877482A9001773F7AD6@orsmsx509.amr.corp.intel.com>
 <20101217140453.GS18990@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Arthur Jones <arthur.jones@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23992 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754391Ab0LQPxS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 10:53:18 -0500
In-Reply-To: <20101217140453.GS18990@ajones-laptop.nbttech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Arthur Jones
>Sent: Friday, December 17, 2010 6:05 AM
>To: Allan, Bruce W
>Cc: Ben Hutchings; Kirsher, Jeffrey T; netdev@vger.kernel.org
>Subject: Re: [PATCH] e1000e: workaround missing power down mii control bit on
>82571
>
>That's not what I saw.  I saw the bit always
>read back zero, even right after I set it.
>
>Have you tried writing the power down bit and
>reading it back?
>
>Arthur

Yes, and it worked as expected.

