From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RESEND 0/2] enable hires timer to timeout datagram socket
Date: Sat, 19 Aug 2017 08:21:45 +0200
Message-ID: <20170819062145.vtr63ri4v577cymz@localhost>
References: <1503081850-10671-1-git-send-email-vallish@amazon.com>
 <20170818201854.xes246oviptinwvq@localhost>
 <20170818222756.GB28737@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shuah@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, eduval@amazon.com,
        anchalag@amazon.com, tglx@linutronix.de
To: Vallish Vaidyeshwara <vallish@amazon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:33848 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750832AbdHSGVu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Aug 2017 02:21:50 -0400
Content-Disposition: inline
In-Reply-To: <20170818222756.GB28737@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 18, 2017 at 10:27:56PM +0000, Vallish Vaidyeshwara wrote:
> We have a on-demand application that uses long timeouts and needs to react to
> events within milliseconds.

Huh?  The test program you posted does not react to any event.

Thanks,
Richard
