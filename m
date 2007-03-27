From: Rick Jones <rick.jones2@hp.com>
Subject: has ethtool been patched for 10 gig speed reporting?
Date: Tue, 27 Mar 2007 11:57:01 -0700
Message-ID: <460968FD.4020202@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:44746 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934179AbXC0S5E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 14:57:04 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel13.hp.com (Postfix) with ESMTP id CE5BD35103
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 11:57:02 -0700 (PDT)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id LAA03851
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 11:57:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have some 10gig nics and ethtool is reporting unknown for the speed. 
Is there already a patch, or have I found an opportunity? FWIW, the 
version five bits from sourceforge still report unknown - are they the 
latest or are there later bits somewhere?

thanks,

rick jones
