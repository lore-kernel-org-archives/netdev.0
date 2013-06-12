From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next stable] sctp: fully initialize sctp_outq in
 sctp_outq_init
Date: Wed, 12 Jun 2013 12:16:37 -0700 (PDT)
Message-ID: <20130612.121637.1916580159961919662.davem@davemloft.net>
References: <1371041959-17697-1-git-send-email-nhorman@tuxdriver.com>
	<51B87CCC.4030200@cogentembedded.com>
	<20130612182404.GG13059@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, linux-sctp@vger.kernel.org,
	vyasevich@gmail.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755220Ab3FLTQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 15:16:40 -0400
In-Reply-To: <20130612182404.GG13059@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 12 Jun 2013 14:24:04 -0400

> On Wed, Jun 12, 2013 at 05:51:08PM +0400, Sergei Shtylyov wrote:
>> Hello.
>> 
>> On 12-06-2013 16:59, Neil Horman wrote:
>> 
>> >In commit 2f94aabd9f6c925d77aecb3ff020f1cc12ed8f86, we modified
>> 
>>     Please also specify that commit's summary line in parens.
>> 
> I don't really think thats necessecary, as it just clutters the commit log, but
> sure, I can add that in.

It is absolutely necessary, as it is the only unambiguous way to refer
to a commit.  And I therefore require it.
