From: Andrew Morton <akpm@osdl.org>
Subject: Re: linux 2.6.9 still having network code problems
Date: Tue, 2 Nov 2004 01:41:19 -0800
Message-ID: <20041102014119.1a6096cc.akpm@osdl.org>
References: <418741EB.3080701@outblaze.com>
	<20041102011918.2b453e21.akpm@osdl.org>
	<4187478A.1040002@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christopher Chan <cchan@outblaze.com>
In-Reply-To: <4187478A.1040002@outblaze.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christopher Chan <cchan@outblaze.com> wrote:
>
> DOH. the kernel swapped the controller order on me...fstab entries 
>  referred to the wrong device names...

Eh?  That shouldn't happen.  Could you please generate a full report of
this, send it to the appropriate list and cc myself?

Although if that's the 2.6.9 behaviour it's probably a bit late to fix it
up.
