From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 14/14] e1000: No-delay link detection at interface up
Date: Fri, 15 Dec 2006 09:50:58 -0500
Message-ID: <4582B652.9060608@garzik.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175754.3365.137.camel@laptopd505.fenrus.org> <4582B2EA.9010501@garzik.org> <4582B341.8030604@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55355 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752681AbWLOOu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 09:50:59 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <4582B341.8030604@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Jeff Garzik wrote:
>> ACK, though you can also just schedule the timer to run immediately, 
>> or even run it yourself inside spin_lock_bh()
> 
> sure but this is very simple, clean and obvious ;)

Hence the ACK...

	Jeff



