From: "Felix Marti" <felix@chelsio.com>
Subject: RE: [PATCH] chelsio 10G (T1/T2)
Date: Tue, 5 Dec 2006 12:01:59 -0800
Message-ID: <8A71B368A89016469F72CD08050AD334E71FD4@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:30746 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968668AbWLEUCN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 15:02:13 -0500
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@osdl.org]
> Sent: Tuesday, December 05, 2006 11:59 AM
> To: Felix Marti
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH] chelsio 10G (T1/T2)
> 
> On Tue, 5 Dec 2006 10:53:10 -0800
> "Felix Marti" <felix@chelsio.com> wrote:
> 
> > T1's and T2's implementation of MSI has a bug. I believe to remember
> > that it
> >
> > works with some chipsets but we should disable MSI by default.
> 
> 
> Is this really the platform bug, if so it should be handled by the pci
quirks
> already. Or is this a Chelsio hardware bug?
[Felix Marti] Chelsio T1 and T2 hardware bug. - T3 works with MSI as
well as MSI-X.

