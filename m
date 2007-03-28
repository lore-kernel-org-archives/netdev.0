From: Rick Jones <rick.jones2@hp.com>
Subject: Re: L2 network namespace benchmarking
Date: Wed, 28 Mar 2007 13:12:03 -0700
Message-ID: <460ACC13.1080906@hp.com>
References: <460997C2.4030902@fr.ibm.com>	<m1ircmunre.fsf@ebiederm.dsl.xmission.com>	<460A1F82.9090108@free.fr>	<m1r6r9r3eo.fsf@ebiederm.dsl.xmission.com>	<460AAF1C.7000102@hp.com> <460AC66A.4060606@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, Dmitry Mishin <dim@openvz.org>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:34809 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965741AbXC1UMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 16:12:09 -0400
In-Reply-To: <460AC66A.4060606@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Do you have any pointer to help on benchmarking the network, perhaps a 
> checklist or some scripts for netperf ?

There are some scripts in doc/examples but they are probably a bit long 
in the tooth by now.

The main writeup _I_ have on netperf would be the manual, which was 
recently updated for the 2.4.3 release.

http://www.netperf.org/svn/netperf2/tags/netperf-2.4.3/doc/netperf.html

or the current top of trunk:

http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html

There is also a netperf-talk@netperf.org mailing list which one can join 
and have discussions about netperf, and a netperf-dev@netperf.org if one 
wants to discuss actual netperf (netperf2 or netperf4) development.

rick jones
