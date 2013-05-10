From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 57851] New: a mistake about macro definition of
 FIB_TABLE_HASHSZ
Date: Fri, 10 May 2013 09:43:03 -0700 (PDT)
Message-ID: <20130510.094303.243008164860684906.davem@davemloft.net>
References: <20130510081854.0c6b95ff@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756621Ab3EJQnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 May 2013 12:43:06 -0400
In-Reply-To: <20130510081854.0c6b95ff@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This has been fixed for nearly 2 months:

commit 5b9e12dbf92b441b37136ea71dac59f05f2673a9
Author: Denis V. Lunev <den@openvz.org>
Date:   Wed Mar 13 00:24:15 2013 +0000

    ipv4: fix definition of FIB_TABLE_HASHSZ
