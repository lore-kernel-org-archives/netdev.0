From: Dave Jones <davej@redhat.com>
Subject: [0/4] trivial cleanups for via-velocity.c
Date: Mon, 20 Jul 2009 23:34:56 -0400
Message-ID: <200907211640.n6LGeG5d011439@gelk.kernelslacker.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52610 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755756AbZGUQkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 12:40:18 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n6LGeJnF001590
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:19 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n6LGeHxD025771
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:18 -0400
Received: from gelk.kernelslacker.org (vpn-10-139.bos.redhat.com [10.16.10.139])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n6LGeHnZ015094
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:17 -0400
Received: from gelk.kernelslacker.org (gelk.kernelslacker.org [127.0.0.1])
	by gelk.kernelslacker.org (8.14.3/8.14.3) with ESMTP id n6LGeHpT011440
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've had these sitting around for a while, they should be safe to apply.
I checked a diff of the disassembly from objdump before/after, and
the only diffs were the placement of the functions & jump offsets changing
due to the reordering in diff 3/4.

	Dave

