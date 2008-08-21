From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user
 with the same regression
Date: Thu, 21 Aug 2008 10:04:24 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808210958340.24674@wrl-59.cs.helsinki.fi>
References: <271523.9227.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, Ingo Molnar <mingo@elte.hu>,
	Vivek Goyal <vgoyal@redhat.com>,
	Bill Fink <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: David Witbrodt <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45949 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755132AbYHUHE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 03:04:28 -0400
In-Reply-To: <271523.9227.qm@web82105.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Aug 2008, David Witbrodt wrote:

> Please advise me on how you would like me to handle 2.6.27 kernels.
> If I use your patch on 2.6.27-rc3, the message scroll off the 80x25 
> screen before I can see them... 

Couldn't you play with CONFIG_BOOT_PRINTK_DELAY?


-- 
 i.
