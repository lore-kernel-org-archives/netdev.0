From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] bug in xfrm_lookup [bugzilla 2017]
Date: Wed, 4 Feb 2004 23:12:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040204231259.0a2888f9.davem@redhat.com>
References: <20040119211156.4bff1640.davem@redhat.com>
	<Pine.LNX.4.44.0402041735320.6034-100000@DYN318430BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0402041735320.6034-100000@DYN318430BLD.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 4 Feb 2004 17:41:48 -0800 (PST)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> One of my earlier patches had a bug in xfrm_lookup() causin schedule()
> to get called though MSG_DONTWAIT was specified. I am going to send
> the following patch to the bugzilla user who created this bug report
> and ask them to test it. I thought I will let you know of this problem
> and I will send you a confirmation once I get a response that the problem
> is solved.

You patch looks correct so I'll apply it for now, if something is
wrong with it send me a fix relative to this patch.

Thanks.
