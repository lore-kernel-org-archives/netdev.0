From: jamal <hadi@cyberus.ca>
Subject: Re: Request: Allocate a Netlink Family Number for MPLS
Date: 01 Dec 2003 16:10:11 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1070313011.1107.39.camel@jzny.localdomain>
References: <Pine.SOL.4.40.0312012012040.27322-100000@gervaise.enst.fr>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ramon Casellas <casellas@infres.enst.fr>
In-Reply-To: <Pine.SOL.4.40.0312012012040.27322-100000@gervaise.enst.fr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2003-12-01 at 14:26, Ramon Casellas wrote:

> 
> Well, we are still coordinating efforts, and Jamal has some design docs
> around... but regardless of the actual implementation, a mechanism to
> communicate with userspace will be needed, and IM(Very, very)HO, netlink
> is a good candidate, analog to rtnetlink, but this is open to discussion.
> 

Please leave this alone because the code i have is taking care of this
(i.e it uses netlink). And the grander plan is to use the same code
for bridging and VLANs as well.
I will share the code once James and everybody else reviews things.

cheers,
jamal
