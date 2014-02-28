From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net] bna: fix vlan tag stripping and implement its toggling
Date: Fri, 28 Feb 2014 10:48:13 +0100
Message-ID: <53105B5D.9060306@redhat.com>
References: <1393578674-12658-1-git-send-email-ivecera@redhat.com> <20140228094203.GA22153@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, rmody@brocade.com,
	jiri@resnulli.us
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32978 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751164AbaB1JsZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 04:48:25 -0500
In-Reply-To: <20140228094203.GA22153@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2014 10:42 AM, Florian Westphal wrote:
>> +int bnad_set_features(struct net_device *dev, netdev_features_t features)
>> >+{
> Nit: static?
Sure... repost.
