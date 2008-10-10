From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: rtl8169_get_stats seems to be adding random crap to
	rx_missed_errors count
Date: Fri, 10 Oct 2008 19:27:31 +0200
Message-ID: <20081010172731.GA19845@electric-eye.fr.zoreil.com>
References: <b2cdc9f30810100947s699dbc76ia72023b08e064816@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml@vger.kernel.org, netdev@vger.kernel.org
To: Alex Bennee <kernel-hacker@bennee.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:47922 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759519AbYJJR1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 13:27:40 -0400
Content-Disposition: inline
In-Reply-To: <b2cdc9f30810100947s699dbc76ia72023b08e064816@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex Bennee <kernel-hacker@bennee.com> :
[...]

It is fixed by patch #0009 at:

http://userweb.kernel.org/~romieu/r8169/2.6.27-rc9/20081007/

-- 
Ueimor
