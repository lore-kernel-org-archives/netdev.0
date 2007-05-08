From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 08 May 2007 01:28:19 -0400
Message-ID: <46400A73.1070201@garzik.org>
References: <m3abwhcy74.fsf@maximus.localdomain>	<m3vef5biob.fsf@maximus.localdomain>	<5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk>	<m3hcqoa772.fsf@maximus.localdomain>	<86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk>	<m33b289zku.fsf@maximus.localdomain> <m3zm4g3yed.fsf_-_@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael-Luke Jones <mlj28@cam.ac.uk>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Krzysztof Halasa <khc@pm.waw.pl>,
	Russell King <rmk@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54481 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967057AbXEHF2Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:28:25 -0400
In-Reply-To: <m3zm4g3yed.fsf_-_@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ACK.

I shall presume that the ARM folks will apply these patches.  You may 
tack on an "Acked-by: Jeff Garzik <jeff@garzik.org>" onto the ethernet 
driver itself.

I'll let the ARM folks review the rest.

I do agree with the comments in the thread that -- as in your most 
recent revision -- the non-eth code belongs in arch/arm.

	Jeff



