From: Al Boldi <a1426z@gawab.com>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Wed, 14 Dec 2005 17:19:47 +0300
Message-ID: <200512141719.47755.a1426z@gawab.com>
References: <200512022253.19029.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932541AbVLNOW5@vger.kernel.org>
To: Bernd Eckenfels <ecki@lina.inka.de>
In-Reply-To: <200512022253.19029.a1426z@gawab.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bernd Eckenfels wrote:
> Al Boldi wrote:
> > The current ip / ifconfig configuration is arcane and inflexible.  The
> > reason being, that they are based on design principles inherited from
> > the last century.
>
> Yes I agree, however note that some of the asumptions are backed up and
> required by RFCs. For example the binding of addresses to interfaces.  This
> is especially strongly required in the IPV6 world with all the scoping and
> renumbering RFCs.

Can you point me to those RFCs? Thanks!

> The things you want to change need to be changed in kernel space, btw.

True.

I mentioned ip / ifconfig not to imply that they are the culprit, but instead 
to expose the underlying kernel implementation.

This does not mean though, that ip / ifconfig cannot offer an emulated OSI 
compliant mode, which would be an impetus to change the underlying 
implementation.

Thanks!

--
Al
