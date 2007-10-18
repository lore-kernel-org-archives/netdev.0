From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] pcnet32:  remove private net_device_stats structure
Date: Wed, 17 Oct 2007 20:28:49 -0400
Message-ID: <4716A8C1.3070305@garzik.org>
References: <1192665979.13749.7.camel@Linux.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60280 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761710AbXJRA2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 20:28:51 -0400
In-Reply-To: <1192665979.13749.7.camel@Linux.home>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> Remove the statistics from the private structure.
> Use the net_device_stats in netn_device structure.
> 
> Following Jeff Garzik's massive cleanup Sep 01.
> pcnet32 was not "low-hanging fruit".
> 
> Tested x86_64.
> 
> Signed-off-by:  Don Fry <pcnet32@verizon.net>

applied


