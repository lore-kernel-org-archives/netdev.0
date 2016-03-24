From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH] net: Fix typos and whitespace.
Date: Wed, 23 Mar 2016 17:28:20 -0700
Message-ID: <CALx6S34KC2cGwvW0RPE_9CEABhrTOrbhkBYb5Eg3PpQ8rspsAg@mail.gmail.com>
References: <20160323134530.18742.35082.stgit@bhelgaas-glaptop2.roam.corp.google.com>
	<20160323.142703.2259993852905081527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhelgaas@google.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:38755 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbcCXA2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 20:28:21 -0400
Received: by mail-ig0-f173.google.com with SMTP id ig19so2791281igb.1
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 17:28:21 -0700 (PDT)
In-Reply-To: <20160323.142703.2259993852905081527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 11:27 AM, David Miller <davem@davemloft.net> wrote:
> From: Bjorn Helgaas <bhelgaas@google.com>
> Date: Wed, 23 Mar 2016 08:45:30 -0500
>
>> Fix typos.  Capitalize CPU, NAPI, RCU consistently.  Align structure
>> indentation.  No functional change intended; only comment and whitespace
>> changes.
>>
>> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
>
> Does not apply to the current 'net' tree, please respin.

Why is this for net and not net-next?
