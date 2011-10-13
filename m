From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 0/8] Request for inclusion: tcp memory buffers
Date: Thu, 13 Oct 2011 16:18:19 -0400 (EDT)
Message-ID: <20111013.161819.264553121596077263.davem@davemloft.net>
References: <4E9744A6.5010101@parallels.com>
	<20111013.161221.1969725742975317077.davem@davemloft.net>
	<4E9746B0.7030603@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
        lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com,
        ebiederm@xmission.com, paul@paulmenage.org, gthelen@google.com,
        netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name,
        avagin@parallels.com, devel@openvz.org
To: glommer@parallels.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4E9746B0.7030603@parallels.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Glauber Costa <glommer@parallels.com>
Date: Fri, 14 Oct 2011 00:14:40 +0400

> Are you happy, or at least willing to accept, an approach that keep
> things as they were with cgroups *compiled out*, or were you referring
> to not in use == compiled in, but with no users?

To me these are the same exact thing, because %99 of users will be running
a kernel with every feature turned on in the Kconfig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
