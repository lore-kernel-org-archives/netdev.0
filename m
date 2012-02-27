From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH v3 2/2] netdev: driver: ethernet: Add TI CPSW driver
Date: Mon, 27 Feb 2012 04:27:16 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E02931790A0F@DBDE01.ent.ti.com>
References: <1330079992-13368-1-git-send-email-mugunthanvnm@ti.com>
	<1330079992-13368-3-git-send-email-mugunthanvnm@ti.com>
 <20120226.141649.1425736441415883291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:50820 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753447Ab2B0E1X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2012 23:27:23 -0500
In-Reply-To: <20120226.141649.1425736441415883291.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, February 27, 2012 12:47 AM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH v3 2/2] netdev: driver: ethernet: Add TI CPSW driver
> 
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Fri, 24 Feb 2012 16:09:52 +0530
> 
> > +struct cpsw_hw_stats {
> 
> Nothing in the driver actually accesses the HW statistics.
> 
> Remove this until it's actually going to be used.

Will remove it.

With regards
Mugunthan V N
