From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Remove X86_TSC dependency in net profile code
Date: Tue, 2 Sep 2003 15:57:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902155750.31390a6e.davem@redhat.com>
References: <20030902230057.GA5424@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20030902230057.GA5424@averell>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 3 Sep 2003 01:00:57 +0200
Andi Kleen <ak@muc.de> wrote:

> I did not actually compile test this because net profile is commented
> out since a long time and doesn't compile. An alternative if noone comes
> up to fix it would be just to remove it completely.

Alexey, time to remove the net profile stuff?
