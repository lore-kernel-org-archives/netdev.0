From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [v2] rtl8xxxu: Don't printk raw binary if serial number is not
 burned in.
Date: Mon, 25 Sep 2017 08:24:19 +0000 (UTC)
Message-ID: <20170925082419.E390860618@smtp.codeaurora.org>
References: <20170908103000.6795-1-kilobyte@angband.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <Jes.Sorensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Stefano Brivio <sbrivio-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Adam Borowski <kilobyte-b9QjgO8OEXPVItvQsEIGlw@public.gmane.org>
To: Adam Borowski <kilobyte-b9QjgO8OEXPVItvQsEIGlw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170908103000.6795-1-kilobyte-b9QjgO8OEXPVItvQsEIGlw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Adam Borowski <kilobyte-b9QjgO8OEXPVItvQsEIGlw@public.gmane.org> wrote:

> I assume that a blank efuse comes with all ones, thus I did not bother
> recognizing other possible junk values.  This matches 100% of dongles
> I've seen (a single Gembird 8192eu).
> 
> Signed-off-by: Adam Borowski <kilobyte-b9QjgO8OEXPVItvQsEIGlw@public.gmane.org>

Patch applied to wireless-drivers-next.git, thanks.

e0a576d74782 rtl8xxxu: Don't printk raw binary if serial number is not burned in.

-- 
https://patchwork.kernel.org/patch/9943635/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
