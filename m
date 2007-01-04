From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.19 and up to  2.6.20-rc2 Ethernet problems x86_64
Date: Thu, 4 Jan 2007 12:46:14 +0100
Message-ID: <20070104114614.GB3175@ff.dom.local>
References: <20061229063254.GA1628@ff.dom.local> <4595CD1B.2020102@blueyonder.co.uk> <20070102115050.GA3449@ff.dom.local> <459A7AF1.5060702@blueyonder.co.uk> <20070103104814.GA2629@ff.dom.local> <459BDFA6.4070109@blueyonder.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964801AbXADLof@vger.kernel.org>
To: Sid Boyce <g3vbv@blueyonder.co.uk>
Content-Disposition: inline
In-Reply-To: <459BDFA6.4070109@blueyonder.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 03, 2007 at 04:53:58PM +0000, Sid Boyce wrote:
...
> It seems >=2.6.19 and the SuSEfirewall are incompatible.

Actually, many programs could be incomapatible with
newer kernel versions, so sometimes upgrades or at
least recompilations are needed. 
  
...
> There is still the problem where the ethernet doesn't get configured 
> with acpi=off which I shall post to the acpi devel list, but this is not 
> a showstopper for me. ifconfig eth0 192.168.10.5 returns SIOCSIFFLAGS: 

I don't know acpi enough but as far as I know
some mainboards can't work properly with acpi
off, so it's probably not a bug.

Cheers,
Jarek P. 
