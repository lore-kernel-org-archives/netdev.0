From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [git patches] 2.6.x more net driver updates
Date: Mon, 27 Jun 2005 08:44:06 -0400
Message-ID: <42BFF496.3040105@pobox.com>
References: <42BFEF86.8090000@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261755AbVF0OvV@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <42BFEF86.8090000@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Please pull from the 'upstream' branch of
> rsync://rsync.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
> 
> to obtain the various changes described in the attachment.

Or, if you wanted to be experimental, you could pull tag (not branch) 
'upstream-20050627-1' of
rsync://rsync.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git

to obtain the same changes.

I think I will start using tags for my submissions, which will eliminate 
an old problem with BK:  After emailing a BitKeeper pull request to you, 
I had to stop pushing to the repo, until you pulled.  With tags, I can 
keep on committing changes, without worrying that you are pulling from a 
moving target.

	Jeff
