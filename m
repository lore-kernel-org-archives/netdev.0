From: Chuck Ebbert <cebbert@redhat.com>
Subject: atl1 driver corrupting memory?
Date: Wed, 25 Jul 2007 14:33:52 -0400
Message-ID: <46A79790.6050203@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763264AbXGYSd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 14:33:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have a report of random errors when using the atl1 driver
with kernel 2.6.22.1. Could that be a problem fixed by the
recent changes to DMA setup in 2.6.23-rc?


