From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH 0/5] atm: Adjustments for some function implementations
Date: Mon, 22 May 2017 21:32:27 -0700
Message-ID: <CAGXu5jLGuH5-dkGd9_JFWAWHUSkubweb-WxD305=n3TORs3-uA@mail.gmail.com>
References: <49543220-93e4-781c-877b-381277837152@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Augusto Mecking Caringi <augustocaringi@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <49543220-93e4-781c-877b-381277837152@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 21, 2017 at 1:12 PM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sun, 21 May 2017 22:09:11 +0200
>
> A few update suggestions were taken into account
> from static source code analysis.
>
> Markus Elfring (5):
>   Improve a size determination in four functions
>   Delete an error message for a failed memory allocation in make_entry()
>   Adjust 19 checks for null pointers
>   Use seq_puts() in lec_info()
>   Use seq_putc() in lec_info()
>
>  net/atm/lec.c | 55 +++++++++++++++++++++++++++----------------------------
>  1 file changed, 27 insertions(+), 28 deletions(-)

These all look fine to me. Thanks!

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

-- 
Kees Cook
Pixel Security
