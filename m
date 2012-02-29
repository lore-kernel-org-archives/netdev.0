From: "Anton 'EvilMan' Danilov" <littlesmilingcloud@gmail.com>
Subject: Re: [PATCH iproute2] pedit action: add mask for changing bits.
Date: Wed, 29 Feb 2012 16:12:27 +0300
Message-ID: <CAEzD07LO9LQR6f_cP7TQ7e9gBCQcnG4O5q0TiALf=Bjyh3cY3g@mail.gmail.com>
References: <CAEzD07+0EA12igqAcwbM8VGKLR9Hp0GjJ7t_Jve=JXOrEKvu9w@mail.gmail.com>
	<1330351135.2384.1039.camel@mojatatu>
	<CAEzD07KenHteg0S8-OfAwqTNTSQdvPOJsA-m_+8CW-8c_HCgnw@mail.gmail.com>
	<1330434308.2369.11.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41881 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754620Ab2B2NM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 08:12:28 -0500
Received: by wgbdr13 with SMTP id dr13so3735387wgb.1
        for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 05:12:27 -0800 (PST)
In-Reply-To: <1330434308.2369.11.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Jamal.

2012/2/28 Jamal Hadi Salim <jhs@mojatatu.com>:
>
> Thinking about this some more:
> Did you try the "retain" option? it is the xor mask to set operation.
>
> I was going to ask you to test the retain in addition to the
> extra mask you are adding on different sets - but i am beginning
> to think the mask you are adding is not needed at all.
>

You are right, mask option isn't needed. Retain option must be used instead it.

>
> As a side note: I think we need an action to work on VLANs since
> they are such an important field. The action would push/pop and edit
> VLAN fields. If you are interested in this, I can help provide guidance
> (It is one of those things on my todo longtimenow but i cant seem to get
> around to it).
>

Action to work on Vlans is fine idea. I'm very interested in this
action. I'll be grateful for any help.

-- 
Anton.
