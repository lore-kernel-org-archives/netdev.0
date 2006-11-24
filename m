From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] Make udp_encap_rcv use pskb_may_pull
Date: Fri, 24 Nov 2006 11:54:15 +0100
Message-ID: <200611241154.15740.netdev@axxeo.de>
References: <20061123000144.GB7452@suse.de> <20061122.201136.129449260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: okir@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:176 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1755095AbWKXKym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Nov 2006 05:54:42 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061122.201136.129449260.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

David Miller wrote:
> From: Olaf Kirch <okir@suse.de>
> Date: Thu, 23 Nov 2006 01:01:44 +0100
> 
> > 
> > Make udp_encap_rcv use pskb_may_pull
> 
> Excellent catch, applied, thanks Olaf.

Should this go to -stable, too? Or are these kernels not affected, yet?

Regards

Ingo Oeser
