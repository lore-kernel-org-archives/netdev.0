From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 11:51:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <61930391.1031313088@[10.10.2.3]>
References: <20020906.113611.102227888.davem@redhat.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gh@us.ibm.com, hadi@cyberus.ca, tcw@tempest.prismnet.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020906.113611.102227888.davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>    The fact that we're doing something different from everyone else
>    and turning up a different set of kernel issues is a good thing, 
>    to my mind. You're right, we could use Tux if we wanted to ... but
>    that doesn't stop Apache being interesting ;-)
> 
> Tux does not obviate Apache from the equation.
> See my other emails.

That's not the point ... we're getting sidetracked here. The
point is: "is this a realistic-ish stick to beat the kernel
with and expect it to behave" ... I feel the answer is yes.

The secondary point is "what are customers doing in the field?"
(not what *should* they be doing ;-)). Moreover, I think the
Apache + Tux combination has been fairly well beaten on already
by other people in the past, though I'm sure it could be done
again.

I see no reason why turning on NAPI should make the Apache setup
we have perform worse ... quite the opposite. Yes, we could use
Tux, yes we'd get better results. But that's not the point ;-)

M.
