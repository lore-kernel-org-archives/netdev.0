From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-2.6.25 1/6][CORE] Remove unneeded ifdefs from sysctl_net_core.c
Date: Mon, 03 Dec 2007 04:06:48 -0700
Message-ID: <m1sl2k11h3.fsf@ebiederm.dsl.xmission.com>
References: <47515A29.3070806@openvz.org>
	<m1tzn13l72.fsf@ebiederm.dsl.xmission.com>
	<4753C511.6090105@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:40201 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbXLCLIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 06:08:39 -0500
In-Reply-To: <4753C511.6090105@openvz.org> (Pavel Emelyanov's message of "Mon,
	03 Dec 2007 11:57:53 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov <xemul@openvz.org> writes:

> Eric W. Biederman wrote:
>> Pavel Emelyanov <xemul@openvz.org> writes:
>> 
>>> They include the whole file, but it is already compiled
>>> out when SYSCTL=n, since it is obj-$(CONFIG_SYSCTL) target
>>> in the Makefile.
>> 
>> Pavel thanks for sending these patches.  Might I ask
>> for some level of acknowledgement when you rework one of
>> my patches and send it off.
>
> Sure. I though I've been doing exactly this thing. I've said
> that unix ctls were from your tree and so on.

Ok.  I guess I must have overlooked that attribution.

>> I suppose this could be a case of duplicate thinking but
>> this patch looks very familiar.
>
> Hm... Do you mean that this one is from your tree? Sorry then,
> I didn't know this. I can resend it with From: <you> if you wish.

It is.  But I don't see any of this as needing a resend.  Please
just don't forget me in the future is all I ask.

Eric
