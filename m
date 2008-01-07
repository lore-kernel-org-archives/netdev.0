From: linux@horizon.com
Subject: Re: 2.6.24-rc6 oops in net_tx_action
Date: 7 Jan 2008 14:13:13 -0500
Message-ID: <20080107191313.6972.qmail@science.horizon.com>
References: <20080107.002342.10040673.davem@davemloft.net>
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, romieu@fr.zoreil.com,
	shemminger@linux-foundation.org
To: davem@davemloft.net, linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:17427 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752319AbYAGTNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 14:13:19 -0500
In-Reply-To: <20080107.002342.10040673.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Thanks!  I got the patch from
>> http://marc.info/?l=linux-netdev&m=119756785219214
>> (Which didn't make it into -rc7; please fix!)
>> and am recompiling now.

> Jeff is busy so he's asked me to pick up the more important
> driver bug fixes that get posted.
>
> I'll push this around, thanks.

Much obliged.  It's only 11 hours of uptime, but no problems so far,
even trying abusive things like "ping -f -l64 -s8000".
