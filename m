From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 16/18] net/irda: convert au1k_ir to platform driver.
Date: Wed, 9 Nov 2011 14:55:55 +0000
Message-ID: <20111109145555.GP19187@linux-mips.org>
References: <1320174224-27305-1-git-send-email-manuel.lauss@googlemail.com>
 <1320174224-27305-17-git-send-email-manuel.lauss@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux-MIPS <linux-mips@linux-mips.org>,
	Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
To: Manuel Lauss <manuel.lauss@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:39654 "EHLO linux-mips.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753862Ab1KIO4G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 09:56:06 -0500
Content-Disposition: inline
In-Reply-To: <1320174224-27305-17-git-send-email-manuel.lauss@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 01, 2011 at 08:03:42PM +0100, Manuel Lauss wrote:

> Moderate driver cleanup:
> convert to platform driver, get rid of board-specific code.
> 
> Driver loads and runs on a DB1100 board.  But since I have no other
> IrDA hardware to exchange data with I can't say whether it really sends
> and receives.
> 
> Cc: Samuel Ortiz <samuel@sortiz.org>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Manuel Lauss <manuel.lauss@googlemail.com>
> ---
> I'd like for this to go in via the MIPS tree since other mips patches depend
> on it.

No (n)acks or comments received so queued for 3.3.  Thanks,

  Ralf
