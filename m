From: David Miller <davem@davemloft.net>
Subject: Re: Backtrace in rds code
Date: Tue, 24 Jan 2012 20:49:25 -0500 (EST)
Message-ID: <20120124.204925.1007060639610978158.davem@davemloft.net>
References: <CA+5PVA7jGq6Hu3ebCzG1FJJStEcsN251Q_0pS9PphkeuAPKxww@mail.gmail.com>
	<20120124.170410.829129930720684609.davem@davemloft.net>
	<CA+5PVA5QFUctweSVYp2OxGAvXOdoxaX6gcsKdKMW6WktyYX6QA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: venkat.x.venkatsubra@oracle.com, netdev@vger.kernel.org
To: jwboyer@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754694Ab2AYBte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 20:49:34 -0500
In-Reply-To: <CA+5PVA5QFUctweSVYp2OxGAvXOdoxaX6gcsKdKMW6WktyYX6QA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Boyer <jwboyer@gmail.com>
Date: Tue, 24 Jan 2012 19:26:25 -0500

> Using the same base kernel as I did to report the issue, plus this patch the
> issue seems to be gone.  I can't really claim rds works overall, but the oops
> output is definitely cleared up.
> 
> Thanks for such a quick turn around.

Thanks for testing, the fix is already in Linus's tree and I'll ship
it off to -stable eventually too.
