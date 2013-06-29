From: David Miller <davem@davemloft.net>
Subject: Re: pull-request vxlan-next
Date: Fri, 28 Jun 2013 22:09:14 -0700 (PDT)
Message-ID: <20130628.220914.1391002839959044176.davem@davemloft.net>
References: <20130625180641.4fa33ceb@nehalam.linuxnetplumber.net>
	<20130628220735.53e6df97@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704Ab3F2FJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 01:09:17 -0400
In-Reply-To: <20130628220735.53e6df97@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 28 Jun 2013 22:07:35 -0700

> On Tue, 25 Jun 2013 18:06:41 -0700
> Stephen Hemminger <stephen@networkplumber.org> wrote:
> 
>> Here is current updates for vxlan in net-next.  It includes Mike's changes
>> to handle multiple destinations and lots of little cosmetic stuff.
>> 
>> This is a fresh vxlan-next repository which was forked from net-next.
>> 
>> ---
>> The following changes since commit 8599b52e14a1611dcb563289421bee76751f1d53:
>> 
>>   bonding: add an option to fail when any of arp_ip_target is inaccessible (2013-06-25 16:58:38 -0700)
>> 
>> are available in the git repository at:
>> 
>>   git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/vxlan-next.git master
>> 
>> for you to fetch changes up to ba609e9bf15bd7df35e2c06a2e5aaf9ab9289b10:
>> 
>>   vxlan: fix function name spelling (2013-06-25 17:06:01 -0700)
>>
> 
> 
> No response? 
> I know pull-requests don't show up patchwork dashboard. Need patches instead?

They do show up for some people, I wonder what magic the patchwork robot
is looking for in the pull request, hmmm...

Anyways, I'm aware of this request now and will process it soon.

But, generally speaking, in the future you should post the patches as
a series and make your "[PATCH 0/N] " posting contain the pull request.
