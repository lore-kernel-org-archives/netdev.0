From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Nearly complete kzalloc cleanup for net/ipv6
Date: Sun, 12 Mar 2006 14:57:01 +0100
Message-ID: <441428AD.3010902@trash.net>
References: <200603112136.43553.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751541AbWCLN6z@vger.kernel.org>
To: Ingo Oeser <ioe-lkml@rameria.de>
In-Reply-To: <200603112136.43553.ioe-lkml@rameria.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Oeser wrote:
> From: Ingo Oeser <ioe-lkml@rameria.de>
> 
> Stupidly use kzalloc() instead of kmalloc()/memset() 
> everywhere where this is possible in net/ipv6/*.c . 
> 
> The netfilter part is NOT included, because Harald should see these, too.

Feel free to send netfilter patches to me.
