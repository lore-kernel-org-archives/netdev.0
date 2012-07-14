From: Hillf Danton <dhillf@gmail.com>
Subject: Re: PROBLEM: Silent data corruption when using sendfile()
Date: Sat, 14 Jul 2012 22:08:41 +0800
Message-ID: <CAJd=RBAJOqJDSBpaaB+2-WU_pa5vChXSf6TbLH8fi3HNt6hZ9w@mail.gmail.com>
References: <20120713171835.GA26052@vault.local>
	<CAJd=RBAntSubDBbJ292SzeoN4hTwBQ_Q23jt+Y6i-+vfrQ5EHQ@mail.gmail.com>
	<1342254042.3265.9017.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Truschnigg <johannes@truschnigg.info>,
	linux-kernel@vger.kernel.org, Willy Tarreau <w@1wt.eu>,
	Linux-Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:62106 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951Ab2GNOIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 10:08:42 -0400
In-Reply-To: <1342254042.3265.9017.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 14, 2012 at 4:20 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Might be, or not (could be a NIC bug)
>
Dunno why sendfile sits in the layer of NIC and
how they interact.
