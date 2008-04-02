From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Fwd: [SPARC64] INO problem Re: [Bug 10273] New: Sun GEM (PCI) -
	network device doesn't work
Date: Wed, 2 Apr 2008 20:26:55 +0200
Message-ID: <20080402182655.GA2739@ami.dom.local>
References: <20080317143624.da313311.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: seraph@xs4all.nl, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:36472 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755970AbYDBSXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 14:23:01 -0400
Received: by nf-out-0910.google.com with SMTP id g13so1214102nfb.21
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2008 11:22:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080317143624.da313311.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Nice work Jos! I forward it to the author and the lists.

Jarek P.

Andrew Morton wrote, On 03/17/2008 10:36 PM:

> On Mon, 17 Mar 2008 14:25:50 -0700 (PDT)
> bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=10273
>>
>>            Summary: Sun GEM (PCI) - network device doesn't work

----- Forwarded message from bugme-daemon@bugzilla.kernel.org -----

> ------- Comment #24 from seraph@xs4all.nl  2008-04-02 07:24 -------
> I did bisection. The bad commit is:
> 
> 5a606b72a4309a656cd1a19ad137dc5557c4b8ea is first bad commit
> commit 5a606b72a4309a656cd1a19ad137dc5557c4b8ea
> Author: David S. Miller <davem@sunset.davemloft.net>
> Date:   Mon Jul 9 22:40:36 2007 -0700
> 
>     [SPARC64]: Do not ACK an INO if it is disabled or inprogress.
> 
> 
> -- 
> Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.

----- End forwarded message -----
