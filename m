From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: Re: Why is ifenslave.c in the kernel tree?
Date: Sun, 22 Feb 2004 20:21:49 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4039014D.8060202@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, hch@lst.de
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:

> Just looking over the 2.6.3 diffs I see that ifenslave is actively
> maintained in Documenation/ of the kernel tree.  Isn't that a _really_
> odd place for a userland tool?  We have a policy of not having any
> userland tools not used for building in the kernel tree, and especially
> none of the distributors will pick it up from there.

The best place could be net-tools package.

But it looks like net-tools is sloppy, last change was done around Apr-2001 !!

--
x86-64 GenuineIntel
