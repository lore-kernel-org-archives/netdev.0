From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [PATCH wireless-dev 0/5] Switch drivers to d80211
Date: Mon, 24 Jul 2006 12:45:57 -0400
Message-ID: <43e72e890607240945o9aad221lcd4a34136bde5c8b@mail.gmail.com>
References: <200607232032.24299.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, "Jiri Benc" <jbenc@suse.cz>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:22758 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932212AbWGXQp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 12:45:59 -0400
Received: by ug-out-1314.google.com with SMTP id m3so2293122ugc
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2006 09:45:57 -0700 (PDT)
To: "Michael Wu" <flamingice@sourmilk.net>
In-Reply-To: <200607232032.24299.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/23/06, Michael Wu <flamingice@sourmilk.net> wrote:
> Hi,
>         This patch series converts a number of fullmac wireless drivers to use
> d80211.h instead of ieee80211.h.

Nice work

> The remaining drivers are hostap, atmel, zd1211rw and ipw*.

I've been working on zd1211rw, give me a week. Anyone started ipw yet?

  Luis
