From: Matthew Galgoci <mgalgoci@redhat.com>
Subject: Re: [patch] kill warning in sk98lin
Date: Fri, 27 Aug 2004 21:23:24 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0408272123050.16018-100000@lacrosse.corp.redhat.com>
References: <20040827182100.585d300f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040827182100.585d300f.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 27 Aug 2004, David S. Miller wrote:

> Date: Fri, 27 Aug 2004 18:21:00 -0700
> From: David S. Miller <davem@davemloft.net>
> To: Matthew Galgoci <mgalgoci@redhat.com>
> Cc: netdev@oss.sgi.com, jgarzik@pobox.com
> Subject: Re: [patch] kill warning in sk98lin
> 
> On Fri, 27 Aug 2004 21:18:57 -0400 (EDT)
> Matthew Galgoci <mgalgoci@redhat.com> wrote:
> 
> > Fix up a warning in sk98lin:
> 
> Why does it warn?  Please provide the warning when fixing
> bugs of this nature, thanks.

Sorry 'bout that.

Module sk98lin cannot be unloaded due to unsafe usage in drivers/net/sk98lin/skge.c:792

-- 
Matthew Galgoci
System Administrator and Sr. Manager of Ruminants
Red Hat, Inc
919.754.3700 x44155
