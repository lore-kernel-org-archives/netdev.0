From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] remove net driver ugliness that sparse complains about
Date: Sat, 29 May 2004 16:00:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40B8EBCB.3010701@pobox.com>
References: <40B8D2F8.6090905@pobox.com> <jeaczraxvu.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@redhat.com>,
        Al Viro <viro@parcelfarce.linux.theplanet.co.uk>,
        Arjan van de Ven <arjanv@redhat.com>,
        Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Schwab <schwab@suse.de>
In-Reply-To: <jeaczraxvu.fsf@sykes.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andreas Schwab wrote:
> These two look wrong, too many &.


thanks, fixed
