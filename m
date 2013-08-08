From: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Subject: Re: Preferred method for configuration
Date: Thu, 08 Aug 2013 07:56:04 +0200
Message-ID: <520332F4.5020206@hhi.fraunhofer.de>
References: <52032D5E.6070307@hhi.fraunhofer.de> <1375940480.2424.135.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.HHI.FRAUNHOFER.DE ([193.174.67.45]:58810 "EHLO
	mailgw.hhi.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753925Ab3HHFzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 01:55:40 -0400
In-Reply-To: <1375940480.2424.135.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resent with list in CC.

Am 08.08.2013 07:41, schrieb Joe Perches:
> On Thu, 2013-08-08 at 07:32 +0200, Thomas Martitz wrote:
>> Hello,
>>
>> I'm developing a NIC driver and currently export some custom
>> configuration settings and actions (e.g. enabling a loopback mode) via
>> sysfs.
>
> Is there some reason you don't want to use ethtool?
>
>

It doesn't allow for custom settings does it? For standards stuff I'm 
sure going to use ethtool.

Best regards.
