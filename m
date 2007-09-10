From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 1/2] remove asm/bitops.h includes
Date: Mon, 10 Sep 2007 13:30:05 +0100
Message-ID: <20070910123005.GB10143@linux-mips.org>
References: <30483262301654323266@pripojeni.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Adrian Bunk <bunk@kernel.org>,
	netdev@vger.kernel.org, rth@twiddle.net, dhowells@redhat.com,
	linux-mips@linux-mips.org
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759327AbXIJMa2@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:47534 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021747AbXIJMaG (ORCPT <rfc822;netdev@vger.kernel.org>
	+ 1 other); Mon, 10 Sep 2007 13:30:06 +0100
Content-Disposition: inline
In-Reply-To: <30483262301654323266@pripojeni.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 08, 2007 at 09:00:08PM +0100, Jiri Slaby wrote:

> 
> remove asm/bitops.h includes
> 
> including asm/bitops directly may cause compile errors. don't include it
> and include linux/bitops instead. next patch will deny including asm header
> directly.
> 
> Cc: Adrian Bunk <bunk@kernel.org>
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

For the MIPS and hamradio bits:

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
