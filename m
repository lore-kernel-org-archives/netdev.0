From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix a kfree(skb) in net/bridge/br_stp_bpdu.c
Date: Wed, 13 Aug 2003 03:37:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813033738.28bc419d.davem@redhat.com>
References: <20030812123126.GD24073@gareth.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
In-Reply-To: <20030812123126.GD24073@gareth.mathematik.tu-chemnitz.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 12 Aug 2003 14:31:26 +0200
Steffen Klassert <klassert@mathematik.tu-chemnitz.de> wrote:

> This patch against 2.6.0-test3 fix an occurence of kfree(skb)
> in net/bridge/br_stp_bpdu.c

Patch applied, thanks.
