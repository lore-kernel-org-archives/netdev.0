From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Sat, 30 Oct 2004 12:34:49 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041030123449.5568d03f@zanzibar.2ka.mipt.ru>
References: <1099030958.4944.148.camel@uganda>
	<Xine.LNX.4.44.0410291342350.22168-100000@thoron.boston.redhat.com>
	<20041030091932.6a74bdae@zanzibar.2ka.mipt.ru>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@redhat.com>, netdev@oss.sgi.com,
        cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20041030091932.6a74bdae@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Oct 2004 09:19:32 +0400
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> On Fri, 29 Oct 2004 13:44:24 -0400 (EDT)
> James Morris <jmorris@redhat.com> wrote:
> 
> > On Fri, 29 Oct 2004, Evgeniy Polyakov wrote:
> > 
> > > I'm pleased to announce asynchronous crypto layer for Linux kernel 2.6.
> > 
> > Could you please resend as a patch against the latest bk snapshot?
> > 
> > i.e. output of 'diff -purN tree-a tree-b'
> > 
> 
> Attached following patches:
> 
> Kconfig.connector.patch
> Kconfig.crypto.patch
> Makefile.connector.patch
> Makefile.crypto.patch
> acrypto.patch
> connector.patch
> 
> Any other files are examples and do not included here.

Forget Kconfig for acrypto.

> > 
> > - James
> > -- 
> > James Morris
> > <jmorris@redhat.com>


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
