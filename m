From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] ethernet: amd: use PTR_RET instead of IS_ERR + PTR_ERR
Date: Tue, 12 Mar 2013 06:58:21 -0400 (EDT)
Message-ID: <20130312.065821.925816158187962930.davem@redhat.com>
References: <1363074487-21248-1-git-send-email-silviupopescu1990@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, geert@linux-m68k.org, joe@perches.com,
	dhowells@redhat.com, linux-kernel@vger.kernel.org
To: silviupopescu1990@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363074487-21248-1-git-send-email-silviupopescu1990@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Date: Tue, 12 Mar 2013 09:48:07 +0200

> This uses PTR_RET instead of IS_ERR and PTR_ERR in order to increase
> readability.
> 
> Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>

Applied.
