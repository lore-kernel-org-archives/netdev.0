From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [patch net-next-2.6] bonding: allow resetting slave failure counters
Date: Wed, 01 Jun 2011 16:11:07 -0300
Message-ID: <4DE68ECB.70802@redhat.com>
References: <4DE63E85.7020508@redhat.com>	<20110601135321.GA2909@psychotron.brq.redhat.com>	<16056.1306944819@death> <20110601.120300.130602301077156524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, jpirko@redhat.com, netdev@vger.kernel.org,
	andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40319 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753328Ab1FATL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 15:11:29 -0400
In-Reply-To: <20110601.120300.130602301077156524.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2011 04:03 PM, David Miller wrote:
> From: Jay Vosburgh <fubar@us.ibm.com>
> Date: Wed, 01 Jun 2011 09:13:39 -0700
> 
>> 	The "this dingus was added in version X.Y.Z" is there because
>> users sometimes read the most recent version of the documentation (that
>> they get from the internet) and then would become confused when their
>> older distro driver lacked some option described in the documentation.
> 
> I disagree with this whole concept, because distros backport features
> like this into their kernel and therefore the feature is showing up in
> version X.Y.$(Z-20).

It doesn't matter the version if the user can find the feature, so
distros backporting features works and that info is not useful at all. 
However, when the user doesn't find the feature and search the internet,
then that info is helpful.

fbl

