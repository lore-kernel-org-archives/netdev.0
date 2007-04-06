From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: network namespace website
Date: Fri, 06 Apr 2007 15:26:54 +0200
Message-ID: <46164A9E.2090705@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Stevens <dlstevens@us.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:17519 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932664AbXDFN06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 09:26:58 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id l36DQvxZ105106
	for <netdev@vger.kernel.org>; Fri, 6 Apr 2007 13:26:57 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l36DQv844059374
	for <netdev@vger.kernel.org>; Fri, 6 Apr 2007 15:26:57 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l36DQuh7032182
	for <netdev@vger.kernel.org>; Fri, 6 Apr 2007 15:26:57 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Eric Biederman has posted a few weeks ago a RFC-patchset concerning the 
network namespace.
I ported it to the 2.6.20 kernel and uploaded the patchset to

http://lxc.sourceforge.net/network.php

For the part I had to used (TCP/UDP-IPV4 with usual ethernet device), I 
found the patchset pretty stable.

You can find in the website:

    - a global description of what is the network namespace
    - a howto for the network namespace configuration
    - a benchmarking matrix
    - the network namespace patchset for 2.6.20 kernel

I hope that can helps to answer what is ? , what for ?, how to use ? 
questions.

If you have any questions or feedbacks, feel free to send an email to 
containers@ mailing list

Thanks.

    -- Daniel





