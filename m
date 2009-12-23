From: Andrey Rahmatullin <wrar@wrar.name>
Subject: Re: via_rhine kernel crashes in 2.6.32
Date: Wed, 23 Dec 2009 21:21:17 +0500
Message-ID: <20091223162117.GA4919@wrars-comp.wrarsdomain>
References: <20091222152658.GA16043@core.hellgate.ch>
 <20091223095203.GA7824@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Roger Luethi <rl@hellgate.ch>,
	Christian Kujau <lists@nerdbynature.de>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756321AbZLWQVZ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091223095203.GA7824@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 23, 2009 at 09:52:03AM +0000, Jarek Poplawski wrote:
> BTW, it seems a change in 2.6.31 might trigger these timeouts more
> often than before. Andrey, could you try if this matters here?
They appear once per 4 seconds with or without this patch.

-- 
WBR, wRAR (ALT Linux Team)
