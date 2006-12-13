From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 0/2] d80211, rt2x00: fixes
Date: Wed, 13 Dec 2006 15:54:49 -0500
Message-ID: <20061213205449.GD26415@csclub.uwaterloo.ca>
References: <20061213180032.241265000.midnight@suse.cz> <20061213171205.GB26415@csclub.uwaterloo.ca> <1166031523.4741.0.camel@localhost.localdomain> <200612131856.58877.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:46441 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750872AbWLMUyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 15:54:50 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200612131856.58877.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 13, 2006 at 06:56:57PM +0100, Ivo van Doorn wrote:
> rt2x00 completely uses the dscape stack, so I am not sure how he is
> managing this wpa without wpa_supplicant with rt2x00.
> Lennart, are you using rt2x00 or the legacy rt2500 driver?

rt2x00 with dscape stack.

--
Len Sorensen
