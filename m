From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [Fwd: [Bug 1692] New: System do a kernel panic in ip_push_pending_frames]
Date: Wed, 17 Dec 2003 13:29:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FE0CAAE.4030600@us.ibm.com>
References: <3FE0C366.1080208@us.ibm.com> <20031217131312.5625814c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031217131312.5625814c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> I bet the problem doesn't occur if he disables preemption in
> his kernel config...

Ah! Hope thats it..

thanks, Dave!

Nivedita
