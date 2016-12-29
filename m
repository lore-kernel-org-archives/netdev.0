From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH] [media] gp8psk: fix spelling mistake: "firmare" ->
 "firmware"
Date: Thu, 29 Dec 2016 21:35:37 +0000
Message-ID: <4ebb4c2e-2adc-d54c-69ce-fee427f0cb48@canonical.com>
References: <20161229202952.27448-1-colin.king@canonical.com>
 <CAA7C2qjAk6LqTru2zimRr4_JUYXK+4d8VENpyYXjyE0-eJ+RKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>,
        Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        "mailing list: linux-media" <linux-media@vger.kernel.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: VDR User <user.vdr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAA7C2qjAk6LqTru2zimRr4_JUYXK+4d8VENpyYXjyE0-eJ+RKQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29/12/16 21:23, VDR User wrote:
>> -                       err("firmare chunk size bigger than 64 bytes.");
>> +                       err("firmware chunk size bigger than 64 bytes.");
> 
> Yup.
> 
>> -                        "HW don't support CMAC encrypiton, use software CMAC encrypiton\n");
>> +                        "HW don't support CMAC encryption, use software CMAC encryption\n");
> 
> Should be: "HW doesn't support CMAC encryption, use software CMAC
> encryption\n");
> 
Very true, I was so focused on the spelling I overlooked the grammar.
I'll re-send with that fixed.

Colin
