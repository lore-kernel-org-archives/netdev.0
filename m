From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH]: altq HFSC port
Date: 26 Jan 2004 09:46:16 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1075128375.1746.392.camel@jzny.localdomain>
References: <Pine.GSO.4.42.0401261228290.22399-200000@stinky.trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@stinky.trash.net>
In-Reply-To: <Pine.GSO.4.42.0401261228290.22399-200000@stinky.trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-01-26 at 07:02, Patrick McHardy wrote:
> This patch is a port of HFSC from altq to Linux 2.6. HFSC is a
> hierarchical packet scheduler which allows flexible resource
> allocation by decoupling of bandwidth and delay. The original
> version and a paper describing HFSC can be found here:
> http://www-2.cs.cmu.edu/~hzhang/HFSC/main.html .

[..]
I think it is a good idea to have this in the kernel. Glad someone
eventually got to it.

> The last issue is the License: The altq version is released under a
> BSD-style License without advertising clause (the original authors
> kindly agreed to remove it). It is my understanding that this is
> compatible with the GPL, and because the code includes some minor
> amounts of GPL'ed code the correct License is GPL and not
> Dual BSD/GPL. I would be glad if someone can confirm that this is
> correct.
> 

This is probably the most contentious issue (given say current SCO
stoopidty).
Have you talked to the original author on this? I think granting you
written consent to move to GPL may be sufficient.

cheers,
jamal

PS:- i will look at the code and give you some feedback.
