From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6]: fix unbalances spin_unlock_bh in
 __xfrm_find_acq_byseq
Date: Thu, 23 Sep 2004 13:23:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923132330.24f5a5f6.davem@davemloft.net>
References: <41524CC8.1070104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41524CC8.1070104@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 23 Sep 2004 06:10:48 +0200
Patrick McHardy <kaber@trash.net> wrote:

> This patch fixes an unbalanced spin_unlock_bh in
> __xfrm_find_acq_byseq left over from the larval
> state SA fix.

Good catch, patch applied.

Thanks Patrick.
