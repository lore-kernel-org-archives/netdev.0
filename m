From: Guy Harris <guy@alum.mit.edu>
Subject: Re: TPACKET_V3 timeout bug?
Date: Tue, 2 May 2017 11:19:27 -0700
Message-ID: <8E434DBC-C285-41A8-8F73-7163BD6FDA04@alum.mit.edu>
References: <20170415194042.GA5936@lunn.ch>
 <20170415224530.GA21010@oracle.com> <20170416021050.GA16418@lunn.ch>
 <251BA382-D82C-4931-A98F-A23AD88F9811@alum.mit.edu>
 <CAAsGZS5ir2Ha1swhdGCg7ibgYRORZykZcu089=oJ51NT4GKDuA@mail.gmail.com>
 <C289F9B5-A8DE-45B1-9485-AE322850B462@alum.mit.edu>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev <netdev@vger.kernel.org>,
        tcpdump-workers <tcpdump-workers@lists.tcpdump.org>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from d.mail.sonic.net ([64.142.111.50]:57300 "EHLO d.mail.sonic.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751220AbdEBSTj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 14:19:39 -0400
In-Reply-To: <C289F9B5-A8DE-45B1-9485-AE322850B462@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 2, 2017, at 10:54 AM, Guy Harris <guy@alum.mit.edu> wrote:

> Yes, there's a case where user space wasn't being woken up.

See also this thread from almost 3 years ago, beginning with

	http://marc.info/?l=linux-netdev&m=140633612828824&w=2

and this patch thread from almost 2 1/2 years ago:

	https://lkml.org/lkml/2014/12/18/466
