From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] atlx: use embedded net_device_stats
Date: Sun, 02 Nov 2008 08:00:48 -0500
Message-ID: <490DA480.6000807@pobox.com>
References: <20081031235202.019379082@vyatta.com> <20081031235325.698875766@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jacliburn@bellsouth.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57890 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753409AbYKBNAy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Nov 2008 08:00:54 -0500
In-Reply-To: <20081031235325.698875766@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> There is now a net_device_stats structure inside net_device that should
> be used if possible by devices. Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

applied 1-2


