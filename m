From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 1/1] add ethtool loopback support
Date: Thu, 08 Apr 2010 13:03:30 -0700
Message-ID: <4BBE3692.7000807@hp.com>
References: <pvmbpdtn8yh.fsf@chavey.mtv.corp.google.com>	<1270751373.5055.22.camel@achroite.uk.solarflarecom.com> <4BBE33C9.5000507@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, chavey@google.com,
	davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:47313 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757876Ab0DHUDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 16:03:34 -0400
In-Reply-To: <4BBE33C9.5000507@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Additionally, ethtool is intended as an interface that exports 
> capabilities generally useful to users.  Is this feature really 
> something that users will make use of?  It seems more in the realm of 
> design validation

In enterprise days gone by, performing loopback tests were a part of hardware 
problem diagnosis in the field - either by SEs or customers.

rick jones
