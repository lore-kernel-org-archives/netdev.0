From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH] xen-netfront: report link speed to ethtool
Date: Fri, 18 Nov 2011 10:46:26 -0800
Message-ID: <4EC6A802.9090805@goop.org>
References: <20111118164805.GA14345@aepfle.de> <1321638394.2883.32.camel@bwh-desktop> <4EC6A778.1000503@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Olaf Hering <olaf@aepfle.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from claw.goop.org ([74.207.240.146]:51390 "EHLO claw.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753040Ab1KRSq2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Nov 2011 13:46:28 -0500
In-Reply-To: <4EC6A778.1000503@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2011 10:44 AM, Rick Jones wrote:
>  It could I suppose, decide 
> based on the physical NIC to which it is attached, so long as folks 
> using the virtual NIC don't expect its attributes to be the same from 
> system to system.

And assuming there's a physical NIC at all.

    J
