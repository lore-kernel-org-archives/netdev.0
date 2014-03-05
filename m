From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2 -next 2/3] include/linux: update xfrm.h
Date: Wed, 05 Mar 2014 09:41:23 +0100
Message-ID: <5316E333.3060700@6wind.com>
References: <1393857367-15016-1-git-send-email-nicolas.dichtel@6wind.com>	<1393857367-15016-2-git-send-email-nicolas.dichtel@6wind.com> <20140304170329.51de98ab@nehalam.linuxnetplumber.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:62106 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbaCEIla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 03:41:30 -0500
Received: by mail-we0-f180.google.com with SMTP id p61so785026wes.11
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 00:41:27 -0800 (PST)
In-Reply-To: <20140304170329.51de98ab@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/03/2014 02:03, Stephen Hemminger a =E9crit :
> On Mon,  3 Mar 2014 15:36:06 +0100
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>
> Sigh. couldn't you have chosen another variable name.
> As it is new kernel headers with old iproute2 source will break.
>
I noticed this after finishing the kernel part.
I have not thought about this because kernel headers are embedded in ip=
route2.
