From: Udo van den Heuvel <udovdh@xs4all.nl>
Subject: Re: kernel: TD structure error TDindex=e
Date: Sun, 20 Jul 2008 18:14:15 +0200
Message-ID: <48836457.2050302@xs4all.nl>
References: <48835302.1090708@xs4all.nl> <20080720160812.GA23652@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758256AbYGTQOa@vger.kernel.org>
In-Reply-To: <20080720160812.GA23652@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Udo van den Heuvel <udovdh@xs4all.nl> :
> [...]
>> 16:41:09 recorder kernel: TD structure error TDindex=e
(...)
>> How can I avoid/fix/etc this situation ?
> 
> Can you apply the patch below to get some more information ?

Will do, will look for an earliest opportinuty to boot the machine with
the patched kernel.

> May I assume that it does not count as a regression ?

Can't confirm/deny.
It has 'hung' before.
