From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFT] covert br2684 to seq_file
Date: Tue, 2 Sep 2003 11:15:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902111543.559452dd.davem@redhat.com>
References: <20030902104308.08ce3fa4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030902104308.08ce3fa4.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Sep 2003 10:43:08 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Convert the /proc/net/atm/br2684 to seq_file interface.
> It builds and runs, but without any real atm hardware the table
> is empty...

Looks fine to me, Chas?
