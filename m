From: VDR User <user.vdr@gmail.com>
Subject: Re: [PATCH] [media] gp8psk: fix spelling mistake: "firmare" -> "firmware"
Date: Thu, 29 Dec 2016 13:23:13 -0800
Message-ID: <CAA7C2qjAk6LqTru2zimRr4_JUYXK+4d8VENpyYXjyE0-eJ+RKQ@mail.gmail.com>
References: <20161229202952.27448-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>,
        Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        "mailing list: linux-media" <linux-media@vger.kernel.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161229202952.27448-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -                       err("firmare chunk size bigger than 64 bytes.");
> +                       err("firmware chunk size bigger than 64 bytes.");

Yup.

> -                        "HW don't support CMAC encrypiton, use software CMAC encrypiton\n");
> +                        "HW don't support CMAC encryption, use software CMAC encryption\n");

Should be: "HW doesn't support CMAC encryption, use software CMAC
encryption\n");
