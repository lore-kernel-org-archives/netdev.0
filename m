From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] TCP burst control
Date: Tue, 6 Jul 2004 17:29:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706172913.590710fe.davem@redhat.com>
References: <20040706160447.3c2efffa.davem@redhat.com>
	<200407070009.i6709wiA026673@ms-smtp-03-eri0.southeast.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, rhee@ncsu.edu, lxu2@ncsu.edu,
        mathis@psc.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: "Injong Rhee" <rhee@eos.ncsu.edu>
In-Reply-To: <200407070009.i6709wiA026673@ms-smtp-03-eri0.southeast.rr.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004 20:09:41 -0400
"Injong Rhee" <rhee@eos.ncsu.edu> wrote:

> Currently with rate having, current Linux tcp stack is full of hacks that in
> fact, hurt the performance of linux tcp (sorry to say this).

If rate-halving is broken, have you taken this up with it's creator,
Mr. Mathis?  What was his response?

I've added him to the CC: list so this can be properly discussed.
