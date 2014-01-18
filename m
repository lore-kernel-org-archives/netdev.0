From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] qlcnic: remove unused code
Date: Fri, 17 Jan 2014 18:04:39 -0800 (PST)
Message-ID: <20140117.180439.826439839013149878.davem@davemloft.net>
References: <20140116103127.121855af@nehalam.linuxnetplumber.net>
	<20140116103221.41637f8f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: himanshu.madhani@qlogic.com, rajesh.borundia@qlogic.com,
	shahed.shaikh@qlogic.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, sucheta.chakraborty@qlogic.com,
	linux-driver@qlogic.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41364 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100AbaARCEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 21:04:40 -0500
In-Reply-To: <20140116103221.41637f8f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 16 Jan 2014 10:32:21 -0800

> Remove function  qlcnic_enable_eswitch which was defined
> but never used in current code.
> 
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
