From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 22 Sep 2004 15:50:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922155031.7068468d.davem@davemloft.net>
References: <20040920063012.GL2825@krispykreme>
	<20040920203021.GD4242@wotan.suse.de>
	<20040921155835.18aee381.davem@davemloft.net>
	<20040922140000.GD27432@wotan.suse.de>
	<20040922111209.7887df53.davem@davemloft.net>
	<20040922195515.GA2619@wotan.suse.de>
	<c0a09e5c04092213126ba5f29d@mail.gmail.com>
	<20040922133906.7d57ef49.davem@davemloft.net>
	<20040922220628.GC2619@wotan.suse.de>
	<20040922152535.7bc81c8a.davem@davemloft.net>
	<20040922224732.GD2619@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040922224732.GD2619@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 23 Sep 2004 00:47:32 +0200
Andi Kleen <ak@suse.de> wrote:

> 22-23MB/s, but not 21MB/s. Ok "breaks completely" was a bit of overstatement,
> admitted.

Right.

Can you do some of the tcp_snd_test() debugging I suggested above
the patch you just tested?  I really need help debugging this
as I cannot reproduce it locally.
