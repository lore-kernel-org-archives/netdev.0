From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] openvswitch tunneling preparation
Date: Fri, 14 Jun 2013 14:04:22 -0700 (PDT)
Message-ID: <20130614.140422.262779440905577037.davem@davemloft.net>
References: <1371147079-29139-1-git-send-email-pshelar@nicira.com>
	<20130613.170527.243134340140974936.davem@davemloft.net>
	<CAEP_g=9fV07wM-LVyfyMy9mjKe+y3pkGz8WvbZAPtM096m7ftw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60854 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985Ab3FNVE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 17:04:26 -0400
In-Reply-To: <CAEP_g=9fV07wM-LVyfyMy9mjKe+y3pkGz8WvbZAPtM096m7ftw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 14 Jun 2013 08:28:41 -0700

> On Thu, Jun 13, 2013 at 5:05 PM, David Miller <davem@davemloft.net> wrote:
>> From: Pravin B Shelar <pshelar@nicira.com>
>> Date: Thu, 13 Jun 2013 11:11:19 -0700
>>
>>> Following patches are required but not directly related to ovs tunneling.
>>> So I am sending them as separate series. These cleanups are already
>>> there in out of tree ovs module.
>>>
>>> Since ovs tunneling series depends on this, I am sending all patches
>>> again.
>>
>> Openvswitch folks please send me a pull request.
> 
> For the non-OVS portions of the tunneling series (not this one, which
> I already applied, but the next) do you want to take them directly or
> should I just throw them all into my tree?

I was hoping you would send me a pull request for the initial 4 patch
series et al.  Then get your ACK's for the openvswitch parts of the big
tunneling patch set so that I could just apply the entire thing myself.
