From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] 2.6.24-mm1 section type conflict cleanup
Date: Mon, 4 Feb 2008 19:04:54 +0100
Message-ID: <20080204180454.GA16050@uranus.ravnborg.org>
References: <20080203171634.58ab668b.akpm@linux-foundation.org> <20080204162223.GA6888@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	apw@shadowen.org, balbir@linux.vnet.ibm.com
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:37518 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751870AbYBDSEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2008 13:04:51 -0500
Content-Disposition: inline
In-Reply-To: <20080204162223.GA6888@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 04, 2008 at 09:52:23PM +0530, Kamalesh Babulal wrote:
> Hi Andrew,
> 
> The 2.6.24-mm1 kernel build fails at many places with section type
> conflict build error.

What arch?
We have troubles with powerpc as pointed out by Al in another thread.

	Sam
