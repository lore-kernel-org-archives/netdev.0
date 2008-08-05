From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: SYSFS support together with NET_NS status?
Date: Tue, 05 Aug 2008 10:01:36 +0200
Message-ID: <489808E0.6000208@fr.ibm.com>
References: <200808050940.59691.andreas.aaen@tietoenator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: containers@lists.linux-foundation.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <gregkh@suse.de>, Tejun Heo <htejun@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Al Viro <viro@ftp.linux.org.uk>,
	Benjamin Thery <benjamin.thery@bull.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andreas B Aaen <andreas.aaen@tietoenator.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:6945 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbYHEICj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 04:02:39 -0400
In-Reply-To: <200808050940.59691.andreas.aaen@tietoenator.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas B Aaen wrote:
> Whats the status of the sysfs support for namespaces? Any idea when this will 
> go upstream - and through which git tree?
> 
> The patches from Eric W. Biederman isn't in the tree
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
> which I have been following.
> 
> Upstream support for sysfs together with namespaces will definately help with 
> more widespread usage of namespaces.

Definitely agree :)

I think the patches should be first in the Greg-KH tree.

Eric asked Greg-KH about this patchset 2 days ago, perhaps I missed it 
but I didn't see any answer yet.

   -- Daniel
