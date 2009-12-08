From: Richard Zidlicky <rz@linux-m68k.org>
Subject: Re: 2.6.32 regression, hard lock
Date: Tue, 8 Dec 2009 21:25:41 +0100
Message-ID: <20091208202541.GB6322@linux-m68k.org>
References: <20091206141419.GA6195@linux-m68k.org> <20091207143057.53c6a362.akpm@linux-foundation.org> <20091208002353.GA30011@linux-m68k.org> <20091207164826.eb2bbc48.akpm@linux-foundation.org> <s5hocm9som6.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Takashi Iwai <tiwai@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:50237 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935789AbZLHUc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 15:32:58 -0500
Content-Disposition: inline
In-Reply-To: <s5hocm9som6.wl%tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2009 at 12:15:45PM +0100, Takashi Iwai wrote:

> 
> But, as Andrew pointed, this should be irrelevant with the IRQ
> lockup.  At most it could be a dead-locking of PA and other
> sound-related processes, but I've never heard the real issue.

indeed, had to kill and restart PA on a few occassions but no other
ill effects so far.

Richard
