From: David Miller <davem@davemloft.net>
Subject: Re: [git pull] rxrpc regression fix
Date: Thu, 09 Apr 2015 23:45:07 -0400 (EDT)
Message-ID: <20150409.234507.493603330504586706.davem@davemloft.net>
References: <20150410023652.GZ889@ZenIV.linux.org.uk>
	<20150409.230156.1114893840261969670.davem@davemloft.net>
	<20150410030757.GC889@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53261 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbbDJDpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 23:45:11 -0400
In-Reply-To: <20150410030757.GC889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Fri, 10 Apr 2015 04:07:57 +0100

> On Thu, Apr 09, 2015 at 11:01:56PM -0400, David Miller wrote:
>> From: Al Viro <viro@ZenIV.linux.org.uk>
>> Date: Fri, 10 Apr 2015 03:36:52 +0100
>> 
>> > Could you pull from
>> > git://git.kernel.org/scm/pub/linux/kernel/git/viro/vfs.git rxrpc-fix
>> 
>> [davem@localhost net]$ git pull git://git.kernel.org/scm/pub/linux/kernel/git/viro/vfs.git rxrpc-fix
>> fatal: remote error: access denied or repository not exported: /scm/pub/linux/kernel/git/viro/vfs.git
> 
> *blink*  Actual URI is
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git rxrpc-fix
> 
> IOW, I'd managed to type path components in the wrong order scmp/pub instead
> of pub/scm.  My apologies...

That works better, pulled, thanks Al.
