From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 1/1] dma-mapping: mark DMA_nBITS_MASK as deprecated fix
Date: Mon, 11 May 2009 11:21:32 +0200
Message-ID: <4A07EE1C.2010705@gmail.com>
References: <20090510085618D.fujita.tomonori@lab.ntt.co.jp>	<1241939066-10178-1-git-send-email-jirislaby@gmail.com> <20090511113659U.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, yanghy@cn.fujitsu.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757362AbZEKJVn@vger.kernel.org>
In-Reply-To: <20090511113659U.fujita.tomonori@lab.ntt.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/11/2009 04:36 AM, FUJITA Tomonori wrote:
> But I think that you need to resend a version of this patch against
> tip. We need this patch in linux-next to warn some new users of these
> deprecated macros.

It depends on Ingo if he doesn't mind to pick it up :).

Anyway I though we want to merge this upstream for 1-2 releases and then
wave and tell it goodbye to propagate not only to linux-next users. I
would resend the patch with an entry in features removal schedule in
that case. But it's up to you...
