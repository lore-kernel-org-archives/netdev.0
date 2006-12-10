From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: baycom_epp.c compile failure
Date: Sun, 10 Dec 2006 12:57:35 +0000
Message-ID: <20061210125735.GA3058@linux-mips.org>
References: <20061210005632.d980f651.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:56880 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759747AbWLJM5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 07:57:41 -0500
Received: from localhost.localdomain ([127.0.0.1]:34508 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20038503AbWLJM5j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Dec 2006 12:57:39 +0000
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061210005632.d980f651.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 10, 2006 at 12:56:32AM -0800, Andrew Morton wrote:

> drivers/net/hamradio/baycom_epp.c: In function 'baycom_probe':
> drivers/net/hamradio/baycom_epp.c:1180: error: 'ax25_nocall' undeclared (first use in this function)
> drivers/net/hamradio/baycom_epp.c:1180: error: (Each undeclared identifier is reported only once
> drivers/net/hamradio/baycom_epp.c:1180: error: for each function it appears in.)

Will look into it later today.

Thanks,

  Ralf
