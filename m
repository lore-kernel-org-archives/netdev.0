From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: the sis190 linux kernel module
Date: Fri, 11 Apr 2008 01:54:10 +0200
Message-ID: <20080410235410.GB22465@electric-eye.fr.zoreil.com>
References: <1207818653.4973.37.camel@linux-q5nk.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sampsa Riikonen <sampsa.riikonen@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:53842 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752389AbYDKAMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 20:12:15 -0400
Content-Disposition: inline
In-Reply-To: <1207818653.4973.37.camel@linux-q5nk.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sampsa Riikonen <sampsa.riikonen@iki.fi> :
[...]
> With the latest kernel (2.6.22.17-0.1-default),
> and using OpenSuse 10.3 I get the following errors:
[...]
> Is there a driver available for the sis191 card or
> should the sis190 driver do the work?

Though far from perfect, the sis190 should (and has actually
been reported to) do the work.

The driver in 2.6.22.something is too old. Please upgrade.

-- 
Ueimor
