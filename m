From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix endianness on tipc subscriber messages
Date: Mon, 08 Mar 2010 12:21:06 -0800 (PST)
Message-ID: <20100308.122106.161169808.davem@davemloft.net>
References: <20100308200315.GE23634@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54871
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755708Ab0CHUUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 15:20:46 -0500
In-Reply-To: <20100308200315.GE23634@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 8 Mar 2010 15:03:15 -0500

> Remove htohl implementation from tipc

Applied, thanks Neil.
