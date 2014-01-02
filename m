From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] qlcnic: Fix loopback diagnostic test
Date: Thu, 02 Jan 2014 17:19:46 -0500 (EST)
Message-ID: <20140102.171946.1398718564941668424.davem@davemloft.net>
References: <1388687925-17882-1-git-send-email-manish.chopra@qlogic.com>
	<1388687925-17882-2-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53969 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbaABWTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:19:50 -0500
In-Reply-To: <1388687925-17882-2-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Thu, 2 Jan 2014 13:38:43 -0500

> o Adapter requires that if the port is in loopback mode no traffic should
>   be flowing through that port, so on arrival of Link up AEN, do not advertise
>   Link up to the stack until port is out of loopback mode
> 
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>

Applied.
