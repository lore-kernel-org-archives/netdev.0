From: "David S. Miller" <davem@redhat.com>
Subject: Re: Linux 2.4.23-pre7 (irda compile fixes)
Date: Sat, 11 Oct 2003 12:16:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031011121635.4eb39ca6.davem@redhat.com>
References: <Pine.LNX.4.44.0310091939100.6403-100000@logos.cnet>
	<20031010162302.GA1526@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: marcelo.tosatti@cyclades.com, linux-kernel@vger.kernel.org,
        irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Hering <olh@suse.de>
In-Reply-To: <20031010162302.GA1526@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Oct 2003 18:23:02 +0200
Olaf Hering <olh@suse.de> wrote:

> The attached patch converts all printk(__FUNCTION__); to
> printk("%s", __FUNCTION__);
> gcc34 doesnt accept the current code anymore, irda doesnt compile.

Applied, thanks Olaf.
