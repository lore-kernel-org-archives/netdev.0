From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH iproute2 v3] fq: allow options of fair queue set to ~0U
Date: Thu, 29 May 2014 10:43:33 +0800
Message-ID: <53869ED5.1090903@huawei.com>
References: <1399868319-2184-1-git-send-email-yangyingliang@huawei.com>	<1399874336.7973.17.camel@edumazet-glaptop2.roam.corp.google.com>	<5370713F.7040701@huawei.com>	<1399908225.7973.25.camel@edumazet-glaptop2.roam.corp.google.com>	<53718221.6040909@huawei.com>	<53719DA4.1010300@huawei.com> <20140528170957.19b50c12@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:1992 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755241AbaE2Cnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 22:43:46 -0400
In-Reply-To: <20140528170957.19b50c12@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/5/29 8:09, Stephen Hemminger wrote:
> On Tue, 13 May 2014 12:20:52 +0800
> Yang Yingliang <yangyingliang@huawei.com> wrote:
> 
>> +	int set_plimit = 0;
>> +	int set_flow_plimit = 0;
>> +	int set_quantum = 0;
>> +	int set_initial_quantum = 0;
>> +	int set_maxrate = 0;
>> +	int set_defrate = 0;
> 
> Please use bool for these since they are boolean flags.
> 
> 
OK, I'll send a v3 later.
