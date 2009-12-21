From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [RFC PATCH v2 2/6] net: Add netif_num_vf function
Date: Mon, 21 Dec 2009 11:34:05 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FD558B2F7@rrsmsx501.amr.corp.intel.com>
References: <20091218013329.4510.25937.stgit@localhost.localdomain>
	<20091218013410.4510.40263.stgit@localhost.localdomain>
 <20091218.200551.39189145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:32806 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834AbZLUSeJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 13:34:09 -0500
In-Reply-To: <20091218.200551.39189145.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>Subject: Re: [RFC PATCH v2 2/6] net: Add netif_num_vf function
>
>
>Well, first of all this won't build without CONFIG_PCI
>defined.
>
>Second of all, we're not putting PCI crap into netdevice.h
>
>Create a generic device layer abstraction by which you can
>fetch these values.
>
>Thanks.

OK, I'll respin this and resubmit after the new year.

-Mitch
