From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 07/22] NET: DM9000: Use msleep() instead of udelay()
Date: Fri, 23 Nov 2007 20:39:45 -0500
Message-ID: <474780E1.2020700@garzik.org>
References: <20071119203910.687238131@fluff.org> <20071119204013.911269341@fluff.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vince@simtec.co.uk
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58381 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752825AbXKXBjr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 20:39:47 -0500
In-Reply-To: <20071119204013.911269341@fluff.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

are you sure you cannot sleep during suspend?

