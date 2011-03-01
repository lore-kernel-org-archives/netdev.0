From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 4/4] bridge: implement slave management
 operations
Date: Tue, 1 Mar 2011 07:19:14 +0100
Message-ID: <20110301061913.GA2855@psychotron.redhat.com>
References: <20110211152125.GA2763@psychotron.brq.redhat.com>
 <20110211152346.GD2763@psychotron.brq.redhat.com>
 <20110228141729.09c3b770@nehalam>
 <20110228144516.0174a9c8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	fubar@us.ibm.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37612 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752148Ab1CAGTX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 01:19:23 -0500
Content-Disposition: inline
In-Reply-To: <20110228144516.0174a9c8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Feb 28, 2011 at 11:45:16PM CET, shemminger@vyatta.com wrote:
>On Mon, 28 Feb 2011 14:17:29 -0800
>Stephen Hemminger <shemminger@linux-foundation.org> wrote:
>
>> On Fri, 11 Feb 2011 16:23:47 +0100
>> Jiri Pirko <jpirko@redhat.com> wrote:
>> 
>> > 
>> > Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> 
>
>Never mind, this is good. I was confusing slave with bridge initialization
>and netdevice ops with ethtool ops.
>
>Ethtool ops seems to be growing like weeds lately...


This was replaced by:
bridge: implement [add/del]_slave ops


never intended to be in ethtool
>
>
>
>-- 
