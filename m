From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Hostess SV-11 depends on INET
Date: Sat, 17 Feb 2007 15:39:48 -0500
Message-ID: <45D76814.7040607@garzik.org>
References: <20070217143752.GF25760@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Baruch Even <baruch@ev-en.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47928 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932851AbXBQUju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 15:39:50 -0500
In-Reply-To: <20070217143752.GF25760@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Baruch Even wrote:
> Comtrol Hostess SV-11 driver uses features from INET but doesn't depend on it.
> The simple solution is to make it depend on INET as happens for the sealevel
> driver.
> 
> Fixes bug #7930.
> 
> Signed-Off-By: Baruch Even <baruch@ev-en.org>

applied


