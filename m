From: "David S. Miller" <davem@redhat.com>
Subject: Re: ip addr flush hangs
Date: Tue, 9 Mar 2004 11:46:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040309114658.23c5c02c.davem@redhat.com>
References: <20040309144824.GD14419@suse.de>
	<20040309150730.GE14419@suse.de>
	<20040309112529.4c013b9c.davem@redhat.com>
	<20040309194426.GA12648@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: okir@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040309194426.GA12648@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 9 Mar 2004 20:44:26 +0100
Andi Kleen <ak@suse.de> wrote:

> The patch was buggy unfortunately - it fixed one case, but broke another.
> Fixing the root cause like Olaf proposes is better.

Ok, I'll review Olaf's patch then.

Thanks.
