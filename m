From: David Miller <davem@davemloft.net>
Subject: Re: 3.10-stable commits missing in 3.12-stable
Date: Fri, 03 Apr 2015 12:22:21 -0400 (EDT)
Message-ID: <20150403.122221.1151334897354117399.davem@davemloft.net>
References: <551E69CA.4040603@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: jslaby@suse.cz
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <551E69CA.4040603@suse.cz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jslaby@suse.cz>
Date: Fri, 03 Apr 2015 12:22:02 +0200

> I am crawling through commits which are in 3.10-stable but are not in
> 3.12-stable. Could you either ACK them so that I can pick them or
> include them in the next stable NETWORKING patches, please?

Sorry, I am not going through arbitrary non-trivial sets of commits.

I'm willing to look at individual -stable backport candidates
on a case by case basis with a well worded and well thought
out justification for each candidate from the person interested
in seeing the -stable submission because it effects something
they care about.

But wholesale collections like this, I'm not going to invest the time
into.  It's not reasonable at all.
