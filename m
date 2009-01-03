From: Robert Hancock <hancockr@shaw.ca>
Subject: Re: Bug/Warning report for the week of January 3rd, 2009
Date: Sat, 03 Jan 2009 17:40:25 -0600
Message-ID: <495FF769.3040205@shaw.ca>
References: <20090103140332.74f39ade@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, x86@kernel.org, netdev@vger.kernel.org,
	tytso@mit.edu, eric@anholt.net, airlied@redhat.com
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from idcmail-mo2no.shaw.ca ([64.59.134.9]:45244 "EHLO
	idcmail-mo2no.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760060AbZACXka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jan 2009 18:40:30 -0500
In-Reply-To: <20090103140332.74f39ade@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arjan van de Ven wrote:
> Rank 2: mtrr_trim_uncached_memory (warning)
> 	Reported 420 times (9816 total reports)
> 	BIOS bug (often in VMWare) where the MTRR's are set up incorrectly or not at all
> 	This warning was last seen in version 2.6.28, and first seen in 2.6.24.
> 	More info: http://www.kerneloops.org/searchweek.php?search=mtrr_trim_uncached_memory

It would be useful if this warning dumped out some DMI BIOS information 
or something, so we could see what systems/boards this was commonly 
happening with..
