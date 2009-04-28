From: David Miller <davem@davemloft.net>
Subject: Re: vlan: update vlan carrier state for admin up/down
Date: Mon, 27 Apr 2009 18:36:40 -0700 (PDT)
Message-ID: <20090427.183640.182469000.davem@davemloft.net>
References: <30658.1240619463@death.nxdomain.ibm.com>
	<49F4BCEB.6040507@candelatech.com>
	<13072.1240876558@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, kaber@trash.net, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39401
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754695AbZD1Bgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 21:36:47 -0400
In-Reply-To: <13072.1240876558@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 27 Apr 2009 16:55:58 -0700

> I'm reluctant to mess with this behavior without knowing why it
> works this way; there may be a good reason for it that I'm not aware
> of.

To be honest I think it's just that this is one huge dark
corner of behavior for many virtual devices, rather than
any of it being intentional.
