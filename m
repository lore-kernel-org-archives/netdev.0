From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1/7] s390: ungrouping a device must not be interruptible
Date: Fri, 31 Aug 2007 06:55:09 -0400
Message-ID: <46D7F38D.6010500@pobox.com>
References: <20070829092651.411517000@linux.vnet.ibm.com> <20070829101843.286542000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	frank.blaschka@de.ibm.com
To: Ursula Braun <braunu@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59550 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964858AbXHaKzO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 06:55:14 -0400
In-Reply-To: <20070829101843.286542000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Applied patches 1-7, after changing the prefix back to "qeth: "

"s390: " prefix should be applied to changes that affect S/390 
architecture platform in general.

This was a patchset specific to a single driver, thus the "qeth: " 
prefix is more informative when looking at a long list of one-line 
change summaries.


