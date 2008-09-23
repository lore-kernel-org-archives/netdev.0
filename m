From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] MIPS checksum fix
Date: Wed, 24 Sep 2008 00:06:14 +0200
Message-ID: <20080923220614.GA10590@linux-mips.org>
References: <20080917.222350.41199051.anemo@mba.ocn.ne.jp> <Pine.LNX.4.55.0809171501450.17103@cliff.in.clinika.pl> <20080918.002705.78730226.anemo@mba.ocn.ne.jp> <Pine.LNX.4.55.0809171917580.17103@cliff.in.clinika.pl> <20080918220734.GA19222@linux-mips.org> <Pine.LNX.4.55.0809190112090.22686@cliff.in.clinika.pl> <20080919112304.GB13440@linux-mips.org> <20080919114743.GA19359@linux-mips.org> <20080919120752.GA19877@linux-mips.org> <BFB5F5A7-2980-4BCB-A14D-9EB6114B031B@terran.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Bryan Phillippe <u1@terran.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([213.58.128.207]:33659 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424AbYIWWS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 18:18:27 -0400
Received: from localhost.localdomain ([127.0.0.1]:60606 "EHLO
	ditditdahdahdah-dahdahdahditdit.dl5rb.org.uk") by ftp.linux-mips.org
	with ESMTP id S28657010AbYIWWGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 23:06:24 +0100
Content-Disposition: inline
In-Reply-To: <BFB5F5A7-2980-4BCB-A14D-9EB6114B031B@terran.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 02:52:24PM -0700, Bryan Phillippe wrote:

> If anyone would like to send me an updated unified diff for this issue, I 
> can re-test today within the next day.

An updated fix is already in the lmo and kernel.org git repositories.

  Ralf
