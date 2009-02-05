From: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Subject: RE: [net-next PATCH] e1000e: normalize usage of serdes_has_link
Date: Wed, 4 Feb 2009 17:23:18 -0800
Message-ID: <A78C6259B11833419567082E2DC0C256C0E7D216@orsmsx508.amr.corp.intel.com>
References: <20090204220434.GD20091@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alex Chiang <achiang@hp.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38493 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755489AbZBEBXV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 20:23:21 -0500
In-Reply-To: <20090204220434.GD20091@ldl.fc.hp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Alex Chiang [mailto:achiang@hp.com]
>Sent: Wednesday, February 04, 2009 2:05 PM
>To: davem@davemloft.net
>Cc: Kirsher, Jeffrey T; jeff@garzik.org; Brandeburg, Jesse; Allan, Bruce W;
>netdev@vger.kernel.org
>Subject: [net-next PATCH] e1000e: normalize usage of serdes_has_link
>
>Cosmetic change to use struct e1000_mac_info.serdes_has_link
>consistently as the 'bool' that it's declared as.
>
>No functional change.
>
>Signed-off-by: Alex Chiang <achiang@hp.com>

Acked-by: Jeff Kirsher <Jeffrey.t.kirsher@intel.com>

Cheers,
Jeff
