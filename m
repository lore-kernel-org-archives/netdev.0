From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Fwd: [Bug 1692] New: System do a kernel panic in
 ip_push_pending_frames]
Date: Wed, 17 Dec 2003 13:13:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031217131312.5625814c.davem@redhat.com>
References: <3FE0C366.1080208@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <3FE0C366.1080208@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 17 Dec 2003 12:58:14 -0800
Nivedita Singhvi <niv@us.ibm.com> wrote:

> Any ideas?

I bet the problem doesn't occur if he disables preemption in
his kernel config...
