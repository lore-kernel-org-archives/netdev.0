From: "David S. Miller" <davem@redhat.com>
Subject: Re: Possible IRDA SKB leaks
Date: Tue, 25 Nov 2003 18:56:19 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125185619.40a004f1.davem@redhat.com>
References: <20031124193042.2c1013a2.davem@redhat.com>
	<20031126023358.GA15162@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, irda-users@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20031126023358.GA15162@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Nov 2003 18:33:58 -0800
Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:

> 	I did the audit, and there was not many places to fix. Tested
> on 2.6.0-test9 (both data and udata path). Patch is trivial and
> attached below.
> 	Thanks for the heads up !

Thanks a lot for following through on this Jean.

Patch applied.
