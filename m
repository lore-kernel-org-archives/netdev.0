From: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Subject: Aw: [PATCH 0068/1285] Replace numeric parameter like 0444 with
 macro
Date: Tue, 2 Aug 2016 13:52:49 +0200
Message-ID: <trinity-d72f06fb-1227-4031-8b47-27278396fb3a-1470138769577@3capp-gmx-bs37>
References: <20160802103819.18288-1-baolex.ni@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: 3chas3@gmail.com, tj@kernel.org, lenb@kernel.org, x86@kernel.org,
	hpa@zytor.com, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com
To: "Baole Ni" <baolex.ni@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:64321 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933719AbcHBMC2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:02:28 -0400
In-Reply-To: <20160802103819.18288-1-baolex.ni@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Gesendet: Dienstag, 02. August 2016 um 12:38 Uhr
> Von: "Baole Ni" <baolex.ni@intel.com>
> An: 3chas3@gmail.com, tj@kernel.org, lenb@kernel.org, x86@kernel.org, hpa@zytor.com
> Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, chuansheng.liu@intel.com, baolex.ni@intel.com
> Betreff: [PATCH 0068/1285] Replace numeric parameter like 0444 with macro
>

just a note: you are using the same patch description for several different 
patches which makes it difficult to distinguish between them.
You should add the driver name in the description, even better also the subystem
like "atm: ambassador: Replace numeric parameter like 0444 with macro"

Regards,
Lino
