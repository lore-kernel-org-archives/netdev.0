From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Wed, 19 Jul 2006 15:52:04 -0400
Message-ID: <20060719155204.0de8882b@localhost.localdomain>
References: <20060718081625.GA13830@2ka.mipt.ru>
	<20060718230121.GA31474@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:33479 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030259AbWGSTyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 15:54:08 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060718230121.GA31474@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As a related note, I am looking into fixing inet hash tables to use RCU.
