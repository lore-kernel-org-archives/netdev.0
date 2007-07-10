From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [1/2] phylib: cleanup marvell.c a bit
Date: Tue, 10 Jul 2007 12:41:48 -0400
Message-ID: <4693B6CC.8070208@garzik.org>
References: <20070703212346.GB26181@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60150 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755434AbXGJQlx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:41:53 -0400
In-Reply-To: <20070703212346.GB26181@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> Simplify the marvell driver init a bit: Make the supported devices an
> array instead of explicitly registering each structure. This makes it
> considerably easier to add new devices down the road.
> 
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

applied 1-2


