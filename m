From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NETLINK]: With opcode INET_DIAG_BC_S_LE dport was
 compared in inet_diag_bc_run()
Date: Tue, 19 Jan 2010 14:12:34 -0800 (PST)
Message-ID: <20100119.141234.151191622.davem@davemloft.net>
References: <4B56291D.2000304@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	linux-kernel@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755062Ab0ASWM1@vger.kernel.org>
In-Reply-To: <4B56291D.2000304@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roel Kluin <roel.kluin@gmail.com>
Date: Tue, 19 Jan 2010 22:50:21 +0100

> The s-port should be compared.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> I presume?

Yep, looks good.

Excellent catch, applied, thanks!
