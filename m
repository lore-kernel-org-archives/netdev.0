From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Remove X86_TSC dependency in net profile code
Date: Thu, 4 Sep 2003 00:44:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030904004451.44f0babe.davem@redhat.com>
References: <20030902230057.GA5424@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
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

I decided to just kill net profile for now.

Thanks for bringing this to my attention Andi.
