From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]  detailled bcm help-2.4.25
Date: Mon, 23 Feb 2004 09:54:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223095454.488ace1f.davem@redhat.com>
References: <403A00AA.3010707@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, netdev@oss.sgi.com, marcelo.tosatti@cyclades.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Xose Vazquez Perez <xose@wanadoo.es>
In-Reply-To: <403A00AA.3010707@wanadoo.es>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 23 Feb 2004 14:31:22 +0100
Xose Vazquez Perez <xose@wanadoo.es> wrote:

> aginst 2.4.25
> 
> This patch adds more realistic information about bcm NICs.
> People only know the commercial names and not about chips names.

Please leave the tigon3, and say something like "tigon3 chips, also
commonly known as NetXtreme..." but even that is garbage because
3com and Alteon call the 57xx based products something else too.

This is why I really hate changes like this :)
