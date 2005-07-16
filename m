From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH] forcedeth: TX handler changes (experimental)
Date: Sat, 16 Jul 2005 23:36:16 +0200
Message-ID: <42D97DD0.6030207__39394.4655931138$1121549903$gmane$org@colorfullife.com>
References: <42D913D6.5050902@colorfullife.com> <42D9658B.7020907@gentoo.org> <42D97B29.4050400@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>, Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <42D97B29.4050400@gentoo.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:

> So, you want this instead:
>
> #define DEV_HAS_LARGEDESC    0x0004
>
Autsch.
Yes, you are right. Sorry for that, I should have reread the patch once 
more. I've fixed it on my website.

--
    Manfred
