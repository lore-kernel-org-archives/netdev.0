From: Chris Snook <csnook@redhat.com>
Subject: Disabling 64-bit DMA on atl1?
Date: Mon, 13 Aug 2007 13:09:56 -0400
Message-ID: <46C09064.206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jacliburn@bellsouth.net>, netdev@vger.kernel.org,
	atl1-devel@lists.sourceforge.net,
	Luca Tettamanti <kronos.it@gmail.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37491 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1032262AbXHMRKm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 13:10:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff --

	Can we please get Luca's patch merged for 2.6.23?  The bug is a data corrupter, 
and the workaround doesn't cost us much.  Both Jay and I have already acked it.

http://lkml.org/lkml/2007/6/25/293

	We'll do it "the right way" once Atheros tracks it down with hardware 
analyzers, but for now, let's fix the data corrupter.

	-- Chris
