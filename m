From: James Morris <jmorris@redhat.com>
Subject: Re: Crypto tests via tcrypt.o modules failes
Date: Fri, 17 Sep 2004 12:09:58 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0409171209190.8510-100000@thoron.boston.redhat.com>
References: <1095434486.32091.2.camel@swoop.gemtek.lt>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Zilvinas Valinskas <zilvinas@gemtek.lt>
In-Reply-To: <1095434486.32091.2.camel@swoop.gemtek.lt>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 17 Sep 2004, Zilvinas Valinskas wrote:

> > I've had a report that all is well on an Xscale PXA (SoC) system, with a 
> > 2.6.7-rc2 kernel.  Are there any significant differences between that and 
> > what you have?
> 2.4.27 and 2.6.7-rc2 I think quite different - can you tell me which
> parts to check for differencies ?

It should work on either kernel (btw, the PXA is little endian, so they 
are different).

-- 
James Morris
<jmorris@redhat.com>
