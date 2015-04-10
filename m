From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [git pull] rxrpc regression fix
Date: Fri, 10 Apr 2015 04:07:57 +0100
Message-ID: <20150410030757.GC889@ZenIV.linux.org.uk>
References: <20150410023652.GZ889@ZenIV.linux.org.uk>
 <20150409.230156.1114893840261969670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:50907 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818AbbDJDH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 23:07:59 -0400
Content-Disposition: inline
In-Reply-To: <20150409.230156.1114893840261969670.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 09, 2015 at 11:01:56PM -0400, David Miller wrote:
> From: Al Viro <viro@ZenIV.linux.org.uk>
> Date: Fri, 10 Apr 2015 03:36:52 +0100
> 
> > Could you pull from
> > git://git.kernel.org/scm/pub/linux/kernel/git/viro/vfs.git rxrpc-fix
> 
> [davem@localhost net]$ git pull git://git.kernel.org/scm/pub/linux/kernel/git/viro/vfs.git rxrpc-fix
> fatal: remote error: access denied or repository not exported: /scm/pub/linux/kernel/git/viro/vfs.git

*blink*  Actual URI is

git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git rxrpc-fix

IOW, I'd managed to type path components in the wrong order scmp/pub instead
of pub/scm.  My apologies...
