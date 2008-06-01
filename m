From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: atl1 card hibernation regression
Date: Sun, 1 Jun 2008 16:49:54 -0500
Message-ID: <20080601164954.102d0fa1@osprey.hogchain.net>
References: <3aa654a40806010742s7529b9fxe02d0204f329065b@mail.gmail.com>
 <20080601134120.3eb6651a@osprey.hogchain.net>
 <3aa654a40806011326o2cfddfa0o6bc743041b5df8d6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@redhat.com>, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Avuton Olrich" <avuton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost02.isp.att.net ([207.115.11.52]:45435 "EHLO
	fmailhost02.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754085AbYFAVuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 17:50:03 -0400
In-Reply-To: <3aa654a40806011326o2cfddfa0o6bc743041b5df8d6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 1 Jun 2008 13:26:26 -0700
"Avuton Olrich" <avuton@gmail.com> wrote:

> On Sun, Jun 1, 2008 at 11:41 AM, Jay Cliburn
> <jacliburn@bellsouth.net> wrote:
> > On Sun, 1 Jun 2008 07:42:02 -0700
> > "Avuton Olrich" <avuton@gmail.com> wrote:
> >
> >> After resuming from hibernate, my network card refuses to get back
> >> online. The bisection and much more information are below.
> >
> > Can you please try this patch?
[...]
> 
> Brilliant! Works as advertised, thanks for the quick fix!

Thank you for the very thorough bug report.

May I include you in the Tested-by line?

Jay
