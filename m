From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: bpf: Enable BPF JIT on ppc32
Date: Fri, 20 Feb 2015 08:26:17 +1100
Message-ID: <1424381177.22771.1.camel@ellerman.id.au>
References: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
	 <20150219.155613.1219259214030608341.davem@davemloft.net>
	 <CAOJe8K0awkwdYNZr5GdRJFQLCJ0F1GOF730Q3UwT7KBJw0c7Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:45350 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751939AbbBSV0U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2015 16:26:20 -0500
In-Reply-To: <CAOJe8K0awkwdYNZr5GdRJFQLCJ0F1GOF730Q3UwT7KBJw0c7Uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-20 at 01:07 +0400, Denis Kirjanov wrote:
> On 2/19/15, David Miller <davem@davemloft.net> wrote:
> > From: Denis Kirjanov <kda@linux-powerpc.org>
> > Date: Tue, 17 Feb 2015 10:04:37 +0300
> >
> >> This patch series enables BPF JIT on ppc32. There are relatevily
> >> few chnages in the code to make it work.
> >>
> >> All test_bpf tests passed both on 7447a and P2041-based machines.
> >>
> >> Changelog:
> >> v1 - > v2: Reordered Kconfig patch in the series
> >
> > Who plans to take this series?  A PowerPC maintainer?
> >
> > If not, should I take it?
> 
> I think that it should go through your tree...

I'm happy for Dave to take it.

But did you test 64-bit as well?

cheers
