From: "David S. Miller" <davem@redhat.com>
Subject: Re: tg3 and machine lockup?
Date: Tue, 15 Jul 2003 22:08:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030715220810.24bf073f.davem@redhat.com>
References: <3F14DD9C.9090807@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F14DD9C.9090807@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2003 22:07:40 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Now, it could be one of a million things...but just curious if anyone
> else has seen anything like this.  Kernel is 2.4.20 + my hacks.

There were tons of locking fixes to the tg3 driver
in 2.4.21
