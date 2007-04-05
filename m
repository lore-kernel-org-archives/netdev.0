From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ethtool: additional 10Gig niceness
Date: Thu, 05 Apr 2007 04:09:22 -0400
Message-ID: <4614AEB2.9000905@garzik.org>
References: <460968FD.4020202@hp.com> <460973A0.8020803@garzik.org> <461443C4.2090702@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52486 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946078AbXDEIJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 04:09:23 -0400
In-Reply-To: <461443C4.2090702@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> teach ethtool to print "10000Mb/s" for a 10G NIC and prepare
> for 10G NICs where it is possible to run something other than 10G
> update the ethtool.8 manpage with info re same and some grammar fixes
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> 
> the likely required asbestos at the ready :)

applied


