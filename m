From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 10/12] headers, can: Add missing #include to <linux/can/bcm.h>
Date: Mon, 08 Aug 2011 17:15:39 +0200
Message-ID: <4E3FFD9B.2050704@hartkopp.net>
References: <1312809302.2591.1139.camel@deadeye> <1312809655.2591.1149.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:48470 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361Ab1HHPPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 11:15:47 -0400
In-Reply-To: <1312809655.2591.1149.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.08.2011 15:20, Ben Hutchings wrote:
> <linux/can/bcm.h> uses type canid_t, defined in <linux/can.h>.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>


Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Thanks Ben!
