From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tools/net: Use include/uapi with __EXPORTED_HEADERS__
Date: Sun, 15 Nov 2015 17:25:24 -0500 (EST)
Message-ID: <20151115.172524.1085087126036976521.davem@davemloft.net>
References: <1447280667-1145-1-git-send-email-kamal@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: kamal@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447280667-1145-1-git-send-email-kamal@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kamal Mostafa <kamal@canonical.com>
Date: Wed, 11 Nov 2015 14:24:27 -0800

> Use the local uapi headers to keep in sync with "recently" added #define's
> (e.g. SKF_AD_VLAN_TPID).  Refactored CFLAGS, and bpf_asm doesn't need -I.
> 
> Fixes: 3f356385e8a449e1d7cfc6b6f8d634ac4f5581a0
> Signed-off-by: Kamal Mostafa <kamal@canonical.com>

Applied and queued up for -stable, thanks.
