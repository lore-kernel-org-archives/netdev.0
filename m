From: Rik van Riel <riel@redhat.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Thu, 31 Mar 2005 07:12:22 -0500 (EST)
Message-ID: <Pine.LNX.4.61.0503310711430.21935@chimarrao.boston.redhat.com>
References: <20050330161522.GH32111@g5.random> <20050331114122.GL24804@muc.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alex Aizman <itn780@yahoo.com>, open-iscsi@googlegroups.com,
        "'jamal'" <hadi@cyberus.ca>, "'Dmitry Yusupov'" <dmitry_yus@yahoo.com>,
        "'James Bottomley'" <James.Bottomley@HansenPartnership.com>,
        mpm@selenic.com, michaelc@cs.wisc.edu, ksummit-2005-discuss@thunk.org,
        "'netdev'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050331114122.GL24804@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Mar 2005, Andi Kleen wrote:

> It wont work - I can guarantee you that if you add a limit like
> "we only support 8 iscsi connections max" then users/customers will raise
> hell because it does not fit their networks.

What would prevent the iscsi driver from telling the network
stack to increase the size of the mempools when additional
iscsi connections are configured ?

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
