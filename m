From: Rick Jones <rick.jones2@hp.com>
Subject: Re: reminder, 2.6.18 window...
Date: Wed, 24 May 2006 14:01:25 -0700
Message-ID: <4474C9A5.1040205@hp.com>
References: <20060523.182217.59656237.davem@davemloft.net>		<447412CA.50303@ipom.com> <4474A489.4080308@garzik.org>		<20060524185644.GF22881@ipom.com> <4474AE92.3030501@garzik.org>		<20060524191442.GG22881@ipom.com> <1148501433.5325.52.camel@jzny2> <4474C5A7.2070703@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Phil Dibowitz <phil@ipom.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:4044 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S932374AbWEXVB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 17:01:29 -0400
To: Brian Haley <brian.haley@hp.com>
In-Reply-To: <4474C5A7.2070703@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So how is this different than if an SNMP station probes my system, then 
> I reboot, then they probe again.  Things will seem to have gone 
> backwards, but they deal with that just fine.

In that case hasn't the system's uptime and/or last boot time in the MIB 
changed and so indicates to the management station that it has been 
rebooted?  It is also possible that the shutdown procedures or the 
rebooting procedures would have generated an SNMP trap to the management 
station(s) informing them of the reboot.

rick jones
