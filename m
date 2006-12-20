From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Network drivers that don't suspend on interface down
Date: Wed, 20 Dec 2006 22:49:33 +0100
Message-ID: <1166651374.3365.1449.camel@laptopd505.fenrus.org>
References: <200612191959.43019.david-b@pacbell.net>
	 <20061220042648.GA19814@srcf.ucam.org>
	 <200612192114.49920.david-b@pacbell.net> <20061220053417.GA29877@suse.de>
	 <20061220055209.GA20483@srcf.ucam.org>
	 <1166601025.3365.1345.camel@laptopd505.fenrus.org>
	 <20061220125314.GA24188@srcf.ucam.org>
	 <1166621931.3365.1384.camel@laptopd505.fenrus.org>
	 <20061220152701.GA22928@dspnet.fr.eu.org>
	 <1166628858.3365.1425.camel@laptopd505.fenrus.org>
	 <20061220164054.GA27938@dspnet.fr.eu.org>
	 <1166635300.3365.1442.camel@laptopd505.fenrus.org>
	 <m3ac1icnd4.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:42008 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965158AbWLTVtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 16:49:36 -0500
To: Benny Amorsen <benny+usenet@amorsen.dk>
In-Reply-To: <m3ac1icnd4.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-12-20 at 21:40 +0100, Benny Amorsen wrote:
> >>>>> "AvdV" == Arjan van de Ven <arjan@infradead.org> writes:
> 
> AvdV> even if you have NO power savings you still don't meet your
> AvdV> criteria. That's basic ethernet for you....
> 
> AvdV> That's what I was trying to say; your criteria is unrealistic
> AvdV> regardless of what the kernel does, ethernet already dictates 30
> AvdV> to 45 seconds there.
> 
> Can you get to such high numbers without STP?

you can get the 30 seconds yes. Usually not with home equipment though,
but with longer cables and expensive switches.. it does happen.

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

