From: Jeff Garzik <jeff@garzik.org>
Subject: Re: PC300too alternative WAN driver
Date: Wed, 31 Jan 2007 05:44:03 -0500
Message-ID: <45C072F3.2020202@garzik.org>
References: <m3hcu85z4v.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55658 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932978AbXAaKoF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 05:44:05 -0500
In-Reply-To: <m3hcu85z4v.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Halasa wrote:
> The attached patch adds an alternative driver "pc300too" for PCI WAN
> cards PC300/RSV and PC300/X21 made by Cyclades Corp. (now Avocent Corp).
> 
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

applied to #upstream

Please make sure to provides updates ensuring that it passes sparse 
checks (see Documentation/sparse.txt)

	Jeff



