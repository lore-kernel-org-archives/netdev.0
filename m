From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Tue, 15 Oct 2002 22:49:36 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210152245390.2762-100000@shell.cyberus.ca>
References: <3DABE5A2.71542192@isg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3DABE5A2.71542192@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 15 Oct 2002, Stefan Rompf wrote:

> Hi Jamal,
>
> attached is the latest version of the patch. Changes:
>
> -Try to use a static struct lw_event for an event. For systems without
> slave devices, this will avoid memory allocation in most cases. But,
> adding code and data it permanently takes as much memory as about ten of
> the additional pointers you didn't want to have in the net_device
> structure ;-)
>

That lw_event is still bothering me ;-> But i dont wanna push it any
further ;-> I think we got some good stuff. Dave and Alexey should make
the call now.

cheers,
jamal
