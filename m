From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH resend 1/4] uapi glibc compat: add libc compat code when
 not build for kernel
Date: Thu, 13 Apr 2017 13:35:12 +0300
Message-ID: <0c2d1429-3c4c-76e7-46c7-a518570783d4@cogentembedded.com>
References: <20170412203103.6057-1-hauke@hauke-m.de>
 <20170412203103.6057-2-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jarod@redhat.com, jogo@openwrt.org,
        david.heidelberger@ixit.cz, maillist-linux@barfooze.de,
        mikko.rapeli@iki.fi, dwmw2@infradead.org
To: Hauke Mehrtens <hauke@hauke-m.de>, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170412203103.6057-2-hauke@hauke-m.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 4/12/2017 11:31 PM, Hauke Mehrtens wrote:

> Instead of checking if this header file is used in the glibc, check if
> iti is not used in kernel context, this way it will also work with

    s/iti/it/.

> other libc implementations like musl.
>
> Acked-by: Mikko Rapeli <mikko.rapeli@iki.fi>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

[...]

MBR, Sergei
