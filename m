From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH iproute2] pedit action: add mask for changing bits.
Date: Wed, 29 Feb 2012 09:01:20 -0500
Message-ID: <1330524080.18226.21.camel@mojatatu>
References: <CAEzD07+0EA12igqAcwbM8VGKLR9Hp0GjJ7t_Jve=JXOrEKvu9w@mail.gmail.com>
	 <1330351135.2384.1039.camel@mojatatu>
	 <CAEzD07KenHteg0S8-OfAwqTNTSQdvPOJsA-m_+8CW-8c_HCgnw@mail.gmail.com>
	 <1330434308.2369.11.camel@mojatatu>
	 <CAEzD07LO9LQR6f_cP7TQ7e9gBCQcnG4O5q0TiALf=Bjyh3cY3g@mail.gmail.com>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:47401 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755335Ab2B2OBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 09:01:24 -0500
Received: by iagj37 with SMTP id j37so2687881iag.19
        for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 06:01:24 -0800 (PST)
In-Reply-To: <CAEzD07LO9LQR6f_cP7TQ7e9gBCQcnG4O5q0TiALf=Bjyh3cY3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Anton,

On Wed, 2012-02-29 at 16:12 +0300, Anton 'EvilMan' Danilov wrote:

> 
> You are right, mask option isn't needed. Retain option must be used instead it.
> 

Thanks for verifying.

> Action to work on Vlans is fine idea. I'm very interested in this
> action. I'll be grateful for any help.

Lets start by defining the interface to be seen by user space
such as vlan editing/popping/pushing etc. Then i will help you
build it slowly until you are comfortable with moving with it.

As a matter of fact, lets talk offline so we dont add more noise
to the list; you can always post the RFC to the list when you are
ready.

cheers,
jamal
