From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC 0/4] xdp: use netlink extended ACK reporting
Date: Tue, 25 Apr 2017 18:54:06 +0200
Message-ID: <20170425185406.3cf2eb91@redhat.com>
References: <20170425080644.122536-1-jakub.kicinski@netronome.com>
        <58FF1157.8030309@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org, davem@davemloft.net,
        johannes@sipsolutions.net, dsa@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl, oss-drivers@netronome.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55212 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1950752AbdDYQyU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 12:54:20 -0400
In-Reply-To: <58FF1157.8030309@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Apr 2017 11:05:27 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> > Where the message is coming directly from the driver.  There could
> > still be a bit of a leap for a complete novice from the message
> > above to the right settings.  I wonder if it would be worthwhile  
> 
> But still 100x better than the current situation. ;) I really
> like the series, thanks for working on this!

+1 thanks for working on this! :-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
