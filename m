From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] additional update of dev_net(net) to struct *net in
 ip_fragment.c, NULL ptr OOPS
Date: Sun, 29 Nov 2009 17:16:28 -0800 (PST)
Message-ID: <20091129.171628.267629074.davem@davemloft.net>
References: <4B0E5AB9.7000103@blue-labs.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david@blue-labs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53813
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752458AbZK3BQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:16:22 -0500
In-Reply-To: <4B0E5AB9.7000103@blue-labs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ford <david@blue-labs.org>
Date: Thu, 26 Nov 2009 05:38:49 -0500

> ipv4 ip_frag_reasm(), fully replace 'dev_net(dev)' with 'net', defined
> previously patched into 2.6.29.

Your patch has been heavily corrupted by your email client, making
the patch unusable.

Please fix this up and resubmit, thank you.
