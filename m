From: jamal <hadi@cyberus.ca>
Subject: Re: Patch resubmission: RFC2863 operstatus for 2.5.50
Date: Thu, 12 Dec 2002 08:21:14 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0212120817001.27784-100000@shell.cyberus.ca>
References: <20021210035532.GA22559@gtf.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stefan Rompf <srompf@isg.de>, "David S. Miller" <davem@redhat.com>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20021210035532.GA22559@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 9 Dec 2002, Jeff Garzik wrote:

> I would summarize his patch as adding variable to represent literally
> ifOperStatus, along with a lock and apparatus to set this variable.
>
> The value may be deduced, without having to literally track it.

If it can be deduced then no point in tracking it.

i think my shepherding of the patch is done at this point. I'll let you
take it from here.

BTW, I still think theres need to clean up the qdisc queues when a link
goes operationaly down.

cheers,
jamal
