From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-velocity: Give RX descriptors to the NIC later on
 open or MTU change
Date: Sun, 03 Jan 2010 21:19:30 -0800 (PST)
Message-ID: <20100103.211930.147976791.davem@davemloft.net>
References: <20091225.182102.112589642.davem@davemloft.net>
	<4B3879FD.60102@computer.org>
	<4B387C03.4070505@computer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	508527@bugs.debian.org
To: jan.ceuleers@computer.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60677
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751853Ab0ADFT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:19:27 -0500
In-Reply-To: <4B387C03.4070505@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Ceuleers <jan.ceuleers@computer.org>
Date: Mon, 28 Dec 2009 10:36:03 +0100

> Jan Ceuleers wrote:
>> I have successfully booted a 2.6.32.2 kernel with this patch applied on top on a PXE-booting machine with nfsroot.
> 
> Obviously this was on a machine with a Via Velocity NIC.

Fair enough, applied to net-2.6, thanks.
