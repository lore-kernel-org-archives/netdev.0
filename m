From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.6.0-test8/9] ethertap oops
Date: Mon, 27 Oct 2003 04:22:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031027042258.21446129.davem@redhat.com>
References: <L1fo.3gb.9@gated-at.bofh.it>
	<m3ekwz7h3z.fsf@averell.firstfloor.org>
	<20031026234828.2cb1f746.davem@redhat.com>
	<20031027122635.GB16013@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, simon.roscic@chello.at, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031027122635.GB16013@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Oct 2003 13:26:35 +0100
Andi Kleen <ak@suse.de> wrote:

> I don't know if it actually fixed the bug, I did not test it
> (sorry, should have stated that in the original mail)
> But at least it should printk now instead of crashing.

Ok, it's still an improvement over the blind dereferencing
it does not.
