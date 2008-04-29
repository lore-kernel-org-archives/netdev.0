From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.25] pcnet32:  delete non NAPI code from driver.
Date: Tue, 29 Apr 2008 02:00:00 -0400
Message-ID: <4816B960.1070400@pobox.com>
References: <1208799695.3619.1.camel@Linux.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53412 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757627AbYD2GAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 02:00:01 -0400
In-Reply-To: <1208799695.3619.1.camel@Linux.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don Fry wrote:
> Delete the non-napi code from the driver and Kconfig.
> Tested x86_64.  Apply at next open opportunity.

ACK, but fails to apply


