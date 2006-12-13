From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 0/2] d80211, rt2x00: fixes
Date: Wed, 13 Dec 2006 17:28:58 -0500
Message-ID: <20061213222858.GA8589@csclub.uwaterloo.ca>
References: <20061213180032.241265000.midnight@suse.cz> <20061213171205.GB26415@csclub.uwaterloo.ca> <1166031523.4741.0.camel@localhost.localdomain> <20061213205425.GC26415@csclub.uwaterloo.ca> <a32f33a40612131328i177600dfh7f6437f4b5ed1bb8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:35316 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751645AbWLMW27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 17:28:59 -0500
To: Ivo Van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <a32f33a40612131328i177600dfh7f6437f4b5ed1bb8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 13, 2006 at 10:28:15PM +0100, Ivo Van Doorn wrote:
> That is definately the rt2500 legacy driver and _not_ the rt2x00 driver.

Yeah I just noticed that a few minutes ago.  I had been trying out both
to see how they worked, and I left the old module loaded by accident.

> Correct, that is why those iwpriv commands are the clear evidence
> you are not using rt2x00 but rt2500 legacy. Check which driver is loaded
> rt2500 means legacy
> rt2500pci means rt2x00.

Yep I am now poking with the wpa_supplicant again, getting other
interesting messages from it.

I will try to give a report on how my system behaves with the 2x00
driver soon since apparently some of my testing was with the wrong
driver.  Oops. :)

--
Len Sorensen
