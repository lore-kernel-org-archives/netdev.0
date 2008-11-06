From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/3] net: Guaranetee the proper ordering of the loopback device.
Date: Thu, 06 Nov 2008 05:02:33 -0800
Message-ID: <m14p2l0zyu.fsf@frodo.ebiederm.org>
References: <48ECA8D2.4090406@openvz.org>
	<m14p2l4v2l.fsf_-_@frodo.ebiederm.org>
	<m1y6zx3gcs.fsf_-_@frodo.ebiederm.org>
	<20081105.160047.174722021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlezcano@fr.ibm.com, containers@lists.osdl.org, den@openvz.org,
	xemul@openvz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:44226 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbYKFNFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 08:05:19 -0500
In-Reply-To: <20081105.160047.174722021.davem@davemloft.net> (David Miller's
	message of "Wed, 05 Nov 2008 16:00:47 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dave can you please drop this one for the moment.

I cleaned up my patch after the basic testing was over and the
result is a kernel that won't boot.  So if we can prevent this
patch from spreading and breaking a git-bisect that would be great.

I will follow up in a moment with a properly tested version.
My apologies.

Eric
