From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] pedit action: add mask for changing bits.
Date: Wed, 25 Apr 2012 13:15:32 -0700
Message-ID: <20120425131532.79ad7e6b@nehalam.linuxnetplumber.net>
References: <CAEzD07+0EA12igqAcwbM8VGKLR9Hp0GjJ7t_Jve=JXOrEKvu9w@mail.gmail.com>
	<1330351135.2384.1039.camel@mojatatu>
	<CAEzD07KenHteg0S8-OfAwqTNTSQdvPOJsA-m_+8CW-8c_HCgnw@mail.gmail.com>
	<1330434308.2369.11.camel@mojatatu>
	<CAEzD07LO9LQR6f_cP7TQ7e9gBCQcnG4O5q0TiALf=Bjyh3cY3g@mail.gmail.com>
	<1330524080.18226.21.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca,
	Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>,
	netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39270 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758558Ab2DYUPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 16:15:36 -0400
In-Reply-To: <1330524080.18226.21.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Feb 2012 09:01:20 -0500
jamal <hadi@cyberus.ca> wrote:

> Hi Anton,
> 
> On Wed, 2012-02-29 at 16:12 +0300, Anton 'EvilMan' Danilov wrote:
> 
> > 
> > You are right, mask option isn't needed. Retain option must be used instead it.
> > 
> 
> Thanks for verifying.
> 
> > Action to work on Vlans is fine idea. I'm very interested in this
> > action. I'll be grateful for any help.
> 
> Lets start by defining the interface to be seen by user space
> such as vlan editing/popping/pushing etc. Then i will help you
> build it slowly until you are comfortable with moving with it.
> 
> As a matter of fact, lets talk offline so we dont add more noise
> to the list; you can always post the RFC to the list when you are
> ready.
> 
> cheers,
> jamal

Did you come to a conclusion, should it be applied as is?
