From: James Morris <jmorris@redhat.com>
Subject: Re: Asynchronous crypto layer.
Date: Fri, 29 Oct 2004 12:16:35 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0410291213380.21689-100000@thoron.boston.redhat.com>
References: <1099062483.1023.21.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: johnpol@2ka.mipt.ru, <netdev@oss.sgi.com>, <cryptoapi@lists.logix.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1099062483.1023.21.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 29 Oct 2004, jamal wrote:

> On Fri, 2004-10-29 at 10:06, Evgeniy Polyakov wrote:
> 
> 
> > If we have a hardware accelerator chip, than we _already_ have improvements 
> > with even the worst async crypto layer, since software and hardware 
> > will work in parrallel.
> 
> Thats what i am hoping - and theory points to it. Numbers, numbers
> please ;->

There's an OpenBSD paper which demonstrates the usefulness of crypto
hardware for reducing cpu contention.  I can't get to their web site now,
but it's there somewhere under a security link.


- James
-- 
James Morris
<jmorris@redhat.com>
