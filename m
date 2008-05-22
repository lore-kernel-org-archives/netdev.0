From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.26 1/3]S2io: Move all the transmit completions to
 a single msi-x (alarm) vector
Date: Thu, 22 May 2008 06:27:00 -0400
Message-ID: <48354A74.3050606@garzik.org>
References: <Pine.GSO.4.10.10805121340300.18446-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60807 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761981AbYEVK1B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:27:01 -0400
In-Reply-To: <Pine.GSO.4.10.10805121340300.18446-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> - Move all the transmit completions to a single msi-x (alarm) vector.
> - Enable the continuous timer interrupt for only one transmit fifo.
> 
> Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

applied 1-3


