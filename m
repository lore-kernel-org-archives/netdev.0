From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch] 2.4.28-rc3: neigh_for_each must be EXPORT_SYMBOL'ed
Date: Sat, 13 Nov 2004 23:25:14 -0800
Message-ID: <20041113232514.61bf760e.davem@davemloft.net>
References: <20041112180052.GE23215@logos.cnet>
	<20041113200735.GD2249@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: marcelo.tosatti@cyclades.com, laforge@gnumonks.org,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	patrick@tykepenguin.com, linux-decnet-user@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261255AbUKNHmi@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041113200735.GD2249@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 13 Nov 2004 21:07:35 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> neigh_for_each must be EXPORT_SYMBOL'ed (as it is in 2.6):

Good catch Adrian, I'll apply this and push it to
Marcelo.

Thanks.
