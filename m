From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] myri10ge: SET_NETDEV_DEV()
Date: Mon, 02 Jul 2007 08:25:02 -0400
Message-ID: <4688EE9E.2080005@garzik.org>
References: <1183043246.2659.19.camel@c64>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brice Goglin <brice@myri.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Maik Hampel <m.hampel@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50909 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753326AbXGBMZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:25:07 -0400
In-Reply-To: <1183043246.2659.19.camel@c64>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maik Hampel wrote:
> SET_NETDEV_DEV() in myri10ge to create the "/sys/class/net/<if>/device"
> symlink.
> 
> Signed-off-by: Maik Hampel <m.hampel@gmx.de>

applied


