From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM]: [clip] delay /proc/net/atm/arp creation
Date: Wed, 11 Feb 2004 22:06:02 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211220602.7ed84984.davem@redhat.com>
References: <200402111432.i1BEWRRr005897@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200402111432.i1BEWRRr005897@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Feb 2004 09:32:29 -0500
chas williams (contractor) <chas@cmf.nrl.navy.mil> wrote:

> this patch delay's creation of /proc/net/atm/arp until
> after the kmem_cache_create.  mea culpa in advance for
> the shoddy #ifdef.
> 
> please apply to 2.6

We can clean up the ifdefs later.

Patch applied.
