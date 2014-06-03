From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ec_bhf: Add runtime dependencies
Date: Mon, 02 Jun 2014 17:02:42 -0700 (PDT)
Message-ID: <20140602.170242.312834831748145787.davem@davemloft.net>
References: <20140531173227.693f6429@endymion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, reksio@newterm.pl
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955AbaFCACn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 20:02:43 -0400
In-Reply-To: <20140531173227.693f6429@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Sat, 31 May 2014 17:32:27 +0200

> The ec_bhf driver is specific to the Beckhoff CX embedded PC series.
> These are based on Intel x86 CPU. So we can add a dependency on
> X86, with COMPILE_TEST as an alternative to still allow for broader
> build-testing.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>

Applied, thanks.
