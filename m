From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 0/7] s390: ctc patches for 2.6.25
Date: Fri, 01 Feb 2008 13:30:55 -0500
Message-ID: <47A3655F.8050808@pobox.com>
References: <20080201145128.462823000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: Ursula Braun <braunu@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37277 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754083AbYBASbB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 13:31:01 -0500
In-Reply-To: <20080201145128.462823000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset breaks git-bisect, by creating interim unbuildable states...


