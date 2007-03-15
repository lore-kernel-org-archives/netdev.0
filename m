From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC] [PATCH] Network Events Connector
Date: Thu, 15 Mar 2007 01:53:37 +0100
Message-ID: <m2veh35nu6.fsf@cerbere.dyndns.info>
References: <m2irecym8t.fsf@cerbere.dyndns.info>
	<20070217163422.GB22369@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 119.235.97-84.rev.gaoland.net ([84.97.235.119]:43501 "EHLO
	cerbere.dyndns.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422796AbXCOAxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 20:53:38 -0400
In-Reply-To: <20070217163422.GB22369@2ka.mipt.ru> (Evgeniy Polyakov's message
	of "Sat, 17 Feb 2007 19:34:22 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:

> On Fri, Feb 09, 2007 at 05:43:14AM +0100, Samir Bellabes (sam@synack.fr) wrote:
>> Hi,
>> 
>> Here is a new feature which can help firewalls to be more application
>> aware, so more useful for people.
>> 
>> Our previous discussion about cn_net and firewalls:
>> http://marc2.theaimsgroup.com/?t=115976957500002&r=1&w=2
>> 
>> Please, I would really like to have feedback and comments on that tool,
>> in order to improve it.
>
> Technical side does have problems.
> 4. are you 100% sure there are misalignments and 32/64 bit userspace
> problems? you seems to copy some bits from proc connector, which
> suffered from that errors in the past.

No, i'm currently not sure of that.

I think you are refering to this : 
http://git.kernel.org/?p=linux/kernel/git/acme/net-2.6.22.git;a=commitdiff;h=af3e095a1fb42bac32355d5d59ce93f8b4e59a3e

I'm going to care of this for cn_net

Evgeniy, thanks a lot for your review.


