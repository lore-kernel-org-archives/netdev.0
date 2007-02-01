From: Rick Jones <rick.jones2@hp.com>
Subject: Re: "meaningful" spinlock contention when bound to non-intr CPU?
Date: Thu, 01 Feb 2007 11:46:17 -0800
Message-ID: <45C24389.80800@hp.com>
References: <45C242C9.1010601@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:52123 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422965AbXBATqS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Feb 2007 14:46:18 -0500
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel11.hp.com (Postfix) with ESMTP id 71894344E0
	for <netdev@vger.kernel.org>; Thu,  1 Feb 2007 11:46:18 -0800 (PST)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id LAA09498
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 11:46:17 -0800 (PST)
In-Reply-To: <45C242C9.1010601@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> A 2.6.10-rc5 kernel onto each system thanks to pointers from Dan Frazier.

gaak - 2.6.20-rc5 that is.
