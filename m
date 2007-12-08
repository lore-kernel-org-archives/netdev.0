From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 3/8] [TFRC/CCID3]: Remove now unused functions /
	function calls
Date: Sat, 8 Dec 2007 15:16:48 -0200
Message-ID: <20071208171641.GD3180@ghostprotocols.net>
References: <11971083882331-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881862-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881667-git-send-email-gerrit@erg.abdn.ac.uk> <11971083883685-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57882 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752269AbXLHRQ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Dec 2007 12:16:59 -0500
Content-Disposition: inline
In-Reply-To: <11971083883685-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sat, Dec 08, 2007 at 10:06:23AM +0000, Gerrit Renker escreveu:
> This removes two things which now have become redundant:
>  1. The function tfrc_rx_hist_entry_delete() is no longer referenced anywhere.
>  2. The CCID3 HC-receiver still inserted timestamps, but received timestamps
>     are not parsed/referenced/used by the HC-sender, it serves no function.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Thanks, applying as two separate patches.

- Arnaldo
