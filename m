From: Sven-Haegar Koch <haegar@sdinet.de>
Subject: Re: linux/vmxnet
Date: Thu, 23 Oct 2008 17:17:16 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.0810231714520.13975@mercury.sdinet.de>
References: <592182.29492.qm@web59608.mail.ac4.yahoo.com> <c0a09e5c0810221825x366dd639h651286ff81f934db@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Michael Chang <michaelcn_chang@yahoo.com>, netdev@vger.kernel.org
To: Andrew Grover <andy.grover@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sdinet.de ([78.47.32.153]:38528 "EHLO mail.sdinet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751254AbYJWPY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2008 11:24:28 -0400
In-Reply-To: <c0a09e5c0810221825x366dd639h651286ff81f934db@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Oct 2008, Andrew Grover wrote:

> On Wed, Oct 22, 2008 at 2:57 PM, Michael Chang
> <michaelcn_chang@yahoo.com> wrote:
> > 1)Is vmxnet opensource. Where can I find its source.
> 
> The vmxnet driver is labeled Vmware Confidential. I got its source by
> looking in the VmwareTools tgz. It's not open source so basically game
> over. Why not try KVM or Xen?

There is an open source version of it under the GPL as part of the 
"Open Virtual Machine Tools", available through

	http://open-vm-tools.sourceforge.net/
	git.opensource.vmware.com/opensource/open-vm-tools/

c'ya
sven

-- 

The Internet treats censorship as a routing problem, and routes around
it. (John Gilmore on http://www.cygnus.com/~gnu/)
