From: Meelis Roos <mroos@linux.ee>
Subject: ipv4_get_l4proto: Frag of proto 17
Date: Tue, 21 Aug 2007 13:56:36 +0300 (EEST)
Message-ID: <Pine.SOC.4.64.0708211355310.24028@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:60425 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755736AbXHUK4m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2007 06:56:42 -0400
Received: from math.ut.ee (math.ut.ee [193.40.36.2])
	by smtp2.it.da.ut.ee (Postfix) with ESMTP id 3113373D9CF
	for <netdev@vger.kernel.org>; Tue, 21 Aug 2007 13:56:36 +0300 (EEST)
Received: from localhost (localhost [127.0.0.1])
	by math.ut.ee (Postfix) with ESMTP id 1E7446ADEB
	for <netdev@vger.kernel.org>; Tue, 21 Aug 2007 13:56:36 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yesterdays git snapsot on a normal home PC spams dmesg with the 
following line:
ipv4_get_l4proto: Frag of proto 17

-- 
Meelis Roos (mroos@linux.ee)
