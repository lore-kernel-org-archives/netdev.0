From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Limit SO_BSDCOMPAT warning
Date: Fri, 24 Oct 2003 19:37:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031024193726.0c269b60.davem@redhat.com>
References: <20031024205707.GA1072@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20031024205707.GA1072@averell>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 24 Oct 2003 22:57:07 +0200
Andi Kleen <ak@muc.de> wrote:

> Warning a few times for each process is enough.

Ok, I'll apply this.  I like this version of a patch limiting this
message, compared to the others that have been submitted, because it
still ensures that every program that has the problem will show up at
least one time in the logs.

Thanks Andi.
