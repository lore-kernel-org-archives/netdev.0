From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [patch net-next] team: add support for non-ethernet devices
Date: Thu, 23 Aug 2012 11:17:03 +0300
Message-ID: <5035E6FF.1040609@mellanox.com>
References: <1345212048-1378-1-git-send-email-jiri@resnulli.us> <CAJZOPZLzL5KMF=HjJ=HZYNUerBXV2Es0cDq9rdP=ZYvsEJv7gA@mail.gmail.com> <20120823080412.GB1592@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:59410 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933736Ab2HWITr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 04:19:47 -0400
In-Reply-To: <20120823080412.GB1592@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/08/2012 11:04, Jiri Pirko wrote:
> You are right. NETIF_F_VLAN_CHALLENGED feature needs to be considered in
> team code.
isn't that the team device has to follow on all the features/offloads of 
the active port?

Or.
