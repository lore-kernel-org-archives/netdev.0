From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH idea - netlink and link changes
Date: Sat, 12 Oct 2002 09:10:30 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210120909450.23509-100000@shell.cyberus.ca>
References: <3DA7EA1B.3D0430F@isg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tim Hockin <thockin@sun.com>, <netdev@oss.sgi.com>,
   <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3DA7EA1B.3D0430F@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 12 Oct 2002, Stefan Rompf wrote:

> IMHO we should merge the patches, taking your one workqueue per device
> approach and my usage of IFF_RUNNING as a mirror bit. What do other
> netdev people think?
>

Only one work queue please, not one per device.

cheers,
jamal
