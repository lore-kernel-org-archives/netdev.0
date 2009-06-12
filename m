From: Rick Jones <rick.jones2@hp.com>
Subject: Netperf 2.4.5 is released.
Date: Thu, 11 Jun 2009 17:30:25 -0700
Message-ID: <4A31A1A1.8050109@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:34173 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbZFLAaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 20:30:24 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [16.89.104.60])
	by g1t0029.austin.hp.com (Postfix) with ESMTP id B5063380C1
	for <netdev@vger.kernel.org>; Fri, 12 Jun 2009 00:30:26 +0000 (UTC)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id RAA12808
	for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 17:30:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks -

I've declared the release of netperf 2.4.5.   You can obtain the sources either 
via subversion from:

http://www.netperf.org/svn/netperf2/tags/netperf-2.4.5

or you can obtain either a compressed tar or zip file from:

ftp://ftp.netperf.org/netperf

where you may chose from netperf-2.4.5.tar.bz2, netperf-2.4.5.tar.gz and
netperf-2.4.5.zip.

I suspect the change of greatest interest to netdev folks will be the fixes, 
courtesy of Andrew Gallatin, for cpu utilization on newer kernels.

happy benchmarking,

rick jones
