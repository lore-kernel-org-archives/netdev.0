From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: fix sparse warning
Date: Thu, 05 Feb 2015 16:05:28 -0800 (PST)
Message-ID: <20150205.160528.29888642619325830.davem@davemloft.net>
References: <1423149883-4717-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: prabhakar.csengg@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423149883-4717-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Date: Thu,  5 Feb 2015 15:24:43 +0000

> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
> 
> this patch fixes following sparse warning:
> 
> be_cmds.c:2750:5: warning: symbol 'be_cmd_set_qos' was not declared. Should it be static?
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Applied.
