From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15868] New: Deleting IP address from interface
 doesn't prevent sending a data.
Date: Wed, 28 Apr 2010 10:02:06 -0400
Message-ID: <20100428100206.e657bbb2.akpm@linux-foundation.org>
References: <bug-15868-10286@https.bugzilla.kernel.org/>
	<20100428074244.304683c7.akpm@linux-foundation.org>
	<20100428.100019.00461804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, Yurij.Plotnikov@oktetlabs.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38736 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753862Ab0D1REX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 13:04:23 -0400
In-Reply-To: <20100428.100019.00461804.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Apr 2010 10:00:19 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 28 Apr 2010 07:42:44 -0400
> 
> > 
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> 
> This is expected behavior.

Yurij says the behavior chnaged.  Was 2.6.25 behaving incorrectly?
