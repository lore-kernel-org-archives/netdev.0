From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Merge p80211 to ieee80211 subsystem
Date: Fri, 25 Mar 2005 04:10:21 -0500
Message-ID: <4243D57D.9050008@pobox.com>
References: <1111740953.17276.84.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S.Miller" <davem@davemloft.net>
To: Zhu Yi <yi.zhu@intel.com>
In-Reply-To: <1111740953.17276.84.camel@debian.sh.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It looks like your mailer word-wrapped the patch, making it impossible 
to apply.  Evolution is, unfortunately, notorious for this.

I recommend using the /usr/sbin/sendmail technique described in

	http://lkml.org/lkml/2005/2/24/3

to send patches.

The sendmail technique guarantees your patch will not be corrupted by 
your MUA, and as a bonus, avoids using attachments (attachments are a 
bit annoying when quoting+replying to patches).

Regards,

	Jeff
