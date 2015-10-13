From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] - gre: add eth_p_teb gro-handler for OVS with gre
 tunnels
Date: Mon, 12 Oct 2015 18:54:12 -0700 (PDT)
Message-ID: <20151012.185412.430924816469153975.davem@davemloft.net>
References: <fc84377af8867930138e05c27952d4d4@imap.linux.ibm.com>
	<CAEP_g=9YKT0hcTBmg2AcJb8+uQCVNd1YHEPoT+M3LA4k-cPFPw@mail.gmail.com>
	<603f81c3c472530ca28263a78576130f@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, tom@herbertland.com, eric.dumazet@gmail.com,
	hkchu@google.com, netdev@vger.kernel.org, jkidambi@us.ibm.com,
	manand@us.ibm.com
To: sramamur@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932092AbbJMBiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 21:38:14 -0400
In-Reply-To: <603f81c3c472530ca28263a78576130f@imap.linux.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Date: Mon, 12 Oct 2015 17:49:13 -0700

> We are using the 3.x kernels and thats why I could not see your fix in
> my tests.

It is inappropriate to submit patches not targetted and tested against
the current sources.
