From: Fernando Gont <fernando@gont.com.ar>
Subject: Re: ICMP attacks against TCP
Date: Thu, 16 Sep 2004 16:34:51 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4.3.2.7.2.20040916162351.00e16d00@pop.gmx.net>
References: <4.3.2.7.2.20040912223315.00df2890@mail.daleclick.com>
 <4.3.2.7.2.20040912223315.00df2890@mail.daleclick.com> <20040913160133.69185327.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Fernando Gont <fernando@gont.com.ar>
In-Reply-To: <20040913160133.69185327.davem@davemloft.net>
References: <4.3.2.7.2.20040912223315.00df2890@mail.daleclick.com>
 <4.3.2.7.2.20040912223315.00df2890@mail.daleclick.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 16:01 13/09/2004 -0700, David S. Miller wrote:

> > There are some other work-arounds (for example, ignoring ICMP Source 
> Quench
> > messages) are not implemented in Linux, though.
>
>I have no problem changing Linux to ignore these ICMP Source Quench
>messages, I completely agree with the draft.  I've made the
>change in both my 2.4.x and 2.6.x trees as follows:

Great!

Thanks so much for your feedback!


--
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@acm.org
