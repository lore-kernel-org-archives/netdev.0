From: "George B." <georgeb@gmail.com>
Subject: Re: Question about vlans, bonding, etc.
Date: Fri, 14 May 2010 00:28:08 -0700
Message-ID: <AANLkTin0oTCakXcIBwDZ4PUKZk0oRYkUUiPUUyEPoF3m@mail.gmail.com>
References: <i2tb65cae941005031706o19a6f1e9zc86b33d73462113f@mail.gmail.com>
	 <1272948506.2407.174.camel@edumazet-laptop>
	 <AANLkTikVJqN6m5nsJsFSNHS_HbOFyt0hGr_8MHu6tWDR@mail.gmail.com>
	 <20100513181218.021aa771@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:45596 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757674Ab0ENH2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 03:28:09 -0400
Received: by pzk42 with SMTP id 42so1209611pzk.4
        for <netdev@vger.kernel.org>; Fri, 14 May 2010 00:28:08 -0700 (PDT)
In-Reply-To: <20100513181218.021aa771@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 13, 2010 at 6:12 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Thu, 13 May 2010 18:10:33 -0700
> "George B." <georgeb@gmail.com> wrote:
>
>> vlan5 on the second interface, vconfig balks that it already exists.
>
> vconfig is stupid. use 'ip link'
>
>
> --
>

It still didn't work but I was using 2.6.32  it works using 2.6.34-rc7
