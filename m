From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Tue, 29 Mar 2005 16:30:52 -0800
Message-ID: <4249F33C.5030407@zytor.com>
References: <1111905181.4753.15.camel@mylaptop> <20050326224621.61f6d917.davem@davemloft.net> <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com> <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave> <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie> <1112130512.1077.107.camel@jzny.localdomain> <Pine.LNX.4.61.0503291659290.15625@chimarrao.boston.redhat.com> <1112137210.1088.17.camel@jzny.localdomain> <20050329232545.GL15453@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Rik van Riel <riel@redhat.com>,
        Dmitry Yusupov <dmitry_yus@yahoo.com>, Andi Kleen <ak@muc.de>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        andrea@suse.de, michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        ksummit-2005-discuss@thunk.org, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20050329232545.GL15453@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matt Mackall wrote:
> 
> I think we first need a software solution that makes no special
> assumptions about hardware capabilities.
>  

Absolutely; having hardware assist will typically reduce, not increase, 
the memory requirements, so the "dumb hardware" solution is likely to be 
the most generic.

	-hpa
