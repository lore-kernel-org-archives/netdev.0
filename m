From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of IRQF_SAMPLE_RANDOM
Date: Mon, 26 May 2008 23:07:02 +0200
Message-ID: <m38wxwepvt.fsf@maximus.localdomain>
References: <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org>
	<482C8550.5000909@intel.com> <482C8D4D.3040702@garzik.org>
	<20080516132107.GA11304@csclub.uwaterloo.ca>
	<20080516161029.44ded734@core>
	<20080516173610.GA27126@csclub.uwaterloo.ca>
	<20080516191125.46f59ad6@core>
	<a24804730805162155m72e6b40aweb8822515c880c50@mail.gmail.com>
	<1211728189.5913.71.camel@andromache> <20080525232712.GF5970@mit.edu>
	<20080526154326.1fe44214@Varda>
	<20080526111458.fff6c311.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alejandro Riveira =?iso-8859-2?Q?Fern=E1ndez?=
	<ariveira@gmail.com>, Theodore Tso <tytso@MIT.EDU>,
	Glen Turner <gdt@gdt.id.au>,
	Chris Peterson <cpeterso@cpeterso.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Jeff Garzik <jeff@garzik.org>,
	"Kok\, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg\, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from OSB1387.piap.pl ([195.187.100.11]:57135 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753338AbYEZVHI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 17:07:08 -0400
In-Reply-To: <20080526111458.fff6c311.billfink@mindspring.com> (Bill Fink's message of "Mon\, 26 May 2008 11\:14\:58 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink <billfink@mindspring.com> writes:

> Another idea that occured to me:  How about using the low order bits
> of the instruction memory address being executed that was interrupted
> by the HZ timer interrupt.

Think of constant-instructions-length processors :-)
-- 
Krzysztof Halasa
