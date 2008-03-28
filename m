From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/11 net-2.6.26] [DCCP]: dccp_v(4|6)_ctl_socket is
 leaked.
Date: Fri, 28 Mar 2008 16:34:27 -0700 (PDT)
Message-ID: <20080328.163427.230723908.davem@davemloft.net>
References: <1206717778.4294.4.camel@iris.sw.ru>
	<20080328164752.GX14945@ghostprotocols.net>
	<1206724191.8599.0.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org, containers@lists.osdl.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55446
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756085AbYC1Xee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 19:34:34 -0400
In-Reply-To: <1206724191.8599.0.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 28 Mar 2008 20:09:51 +0300

> seems logical. OK, I'll redo this.

I'm dropping this patch set for now, please make a full
resubmission when you've done the fixups.

Thanks!
