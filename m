From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: inaccurate packet scheduling
Date: Wed, 2 Jan 2013 16:26:01 +0100
Message-ID: <20130102152601.GB1532@minipsycho.orion>
References: <e2f71dc7-bee5-41ca-bd64-f4569fa953da@tahiti.vyatta.com>
 <1355849503.9380.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edumazet@google.com, netdev@vger.kernel.org
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:65014 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752714Ab3ABP0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 10:26:08 -0500
Received: by mail-ee0-f53.google.com with SMTP id c50so7124080eek.40
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2013 07:26:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1355849503.9380.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 18, 2012 at 05:51:43PM CET, erdnetdev@gmail.com wrote:
>On Tue, 2012-12-18 at 08:26 -0800, Stephen Hemminger wrote:
>
>> Check kernel log for messages about clock. It could be that on the
>> machines with issues TSC is not usable for kernel clock.
>> Also turn off TSO since it screws up any form of rate control.
>
>Yes, but we should fix it eventually. I'll take a look.

Hi Eric, did you have a chance to look at this? Or should I give it a try?

Thanks a lot.

Jiri

>
>
>
