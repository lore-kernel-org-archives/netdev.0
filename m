From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] unexport xfrm_policy_delete
Date: Tue, 18 Jan 2005 12:38:09 -0800
Message-ID: <20050118123809.3a051164.davem@davemloft.net>
References: <20050118102932.GD4274@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261409AbVARUms@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050118102932.GD4274@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Jan 2005 11:29:32 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> I haven't found any way how xfrm_policy_delete could be called from 
> modular code in 2.6.11-rc1-mm1.
> 
> Unless I'm wrong or a patch for a modular usage is pending, I'm 
> therefore suggesting this patch for removing the EXPORT_SYMBOL.

Looks good to me, applied.

Thanks Adrian.
