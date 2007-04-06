From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Fri, 6 Apr 2007 13:07:27 +0200
Message-ID: <20070406110727.GA1701@elte.hu>
References: <4613CC01.1090500@qumranet.com> <4613CDB2.4000903@codemonkey.ws> <4613D001.3040606@qumranet.com> <20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com> <20070404212103.GA19026@elte.hu> <1175728768.12230.593.camel@localhost.localdomain> <20070405093033.GC25448@elte.hu> <4615086C.9060306@us.ibm.com> <20070406103746.GA24596@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	kvm-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>
To: Anthony Liguori <aliguori@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:50058 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1766729AbXDFLHp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2007 07:07:45 -0400
Content-Disposition: inline
In-Reply-To: <20070406103746.GA24596@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> * Anthony Liguori <aliguori@us.ibm.com> wrote:
> 
> > [...] Did Linux have extremely high quality code in 1994?
> 
> yes! It was crutial to strive for extremely high quality code all the 
> time. That was the only way to grow Linux's codebase, which was 
> ~300,000 lines of code in 1994, to the current 7.2+ million lines of 
> code, without losing maintainability. [...]

in fact Linux 1.0, released in early 1994, was only 170,000 LOC:

  http://www.kernel.org/pub/linux/kernel/v1.0/linux-1.0.tar.gz

and i just looked at a few random files in it - it's pretty clean.

	Ingo
