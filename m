From: James Morris <jmorris@redhat.com>
Subject: Re: oops in skbuff.c
Date: Thu, 16 Oct 2003 16:37:07 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Xine.LNX.4.44.0310161635590.6371-100000@thoron.boston.redhat.com>
References: <3F8F152F.4147.5743B2C@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LK-net <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Sebastian Piecha <spi@gmxpro.de>
In-Reply-To: <3F8F152F.4147.5743B2C@localhost>
List-Id: netdev.vger.kernel.org

On Thu, 16 Oct 2003, Sebastian Piecha wrote:

> On 16 Oct 2003 at 15:15, James Morris wrote:
> > On Thu, 16 Oct 2003, Sebastian Piecha wrote:
> > 
> > Does the above cause a panic for the 2.6-test kernels?
> > Do you have netfilter enabled, and if so, any iptables modules loaded?
> > 
> No. Only in 2.4-kernels. No netfilter. No iptables. Just samba 
> sharing some reiserfs directories on a Promise attached ide harddisk.

Are you able to test with a different NIC to the onboard 3C905B?


- James
-- 
James Morris
<jmorris@redhat.com>


