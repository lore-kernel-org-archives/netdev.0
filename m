From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 04/22] NET: DM9000: Add initial ethtool support
Date: Fri, 23 Nov 2007 20:38:02 -0500
Message-ID: <4747807A.3070302@garzik.org>
References: <20071119203910.687238131@fluff.org> <20071119204013.403622199@fluff.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vince@simtec.co.uk
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36671 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752419AbXKXBiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 20:38:03 -0500
In-Reply-To: <20071119204013.403622199@fluff.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


if ETHTOOL_GDRVINFO bus info is not PCI, you must add a prefix a la 
3c59x.c or eepro.c


