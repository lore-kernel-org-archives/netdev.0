From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 1/3] Revert "icmp: avoid allocating large
 struct on stack"
Date: Mon, 9 Jan 2017 21:53:36 +0100
Message-ID: <20170109215336.7699afd8@redhat.com>
References: <1483984208.5846.9.camel@edumazet-glaptop3.roam.corp.google.com>
        <CAM_iQpV6YQ6nh_Y0f3BDgMheOic3bPiqQ1oNHR+saxxE7nBuoA@mail.gmail.com>
        <1483985224.21472.3.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170109.135259.988711786570465428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, xiyou.wangcong@gmail.com,
        netdev@vger.kernel.org, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41990 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933081AbdAIUxk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 15:53:40 -0500
In-Reply-To: <20170109.135259.988711786570465428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 09 Jan 2017 13:52:59 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com> 
> Date: Mon, 09 Jan 2017 10:07:04 -0800
> 
> > You really should come to netdev conferences so that you understand
> > goals and efforts, instead of living in your cave.  
> 
> I completely agree with Eric.
> 
> Cong we have a very serious problem with you exactly because you make
> quite vicious emotional statements targetted at other developers
> merely when they say something you disagree with.
> 
> This is completely unacceptable behavior, and you must stop doing
> this, now.

I agree, and it is even documented in:
 Documentation/process/code-of-conflict.rst

Quote: "As a reviewer of code, please strive to keep things civil and
focused on the technical issues involved. [...]"

https://www.kernel.org/doc/html/latest/process/code-of-conflict.html

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
