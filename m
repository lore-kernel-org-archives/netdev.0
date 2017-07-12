From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH v2 03/22] net: broadcom: stop using rtc deprecated functions
Date: Wed, 12 Jul 2017 13:01:33 -0700
Message-ID: <CACKFLinuS_crvAoXZnHJR8kPY_vs+egW=yXJvbAx6vd6bqQRGg@mail.gmail.com>
References: <1499846682-14093-1-git-send-email-benjamin.gaignard@linaro.org> <1499846682-14093-4-git-send-email-benjamin.gaignard@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linaro-kernel@lists.linaro.org, Netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Benjamin Gaignard <benjamin.gaignard@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499846682-14093-4-git-send-email-benjamin.gaignard@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 12, 2017 at 1:04 AM, Benjamin Gaignard
<benjamin.gaignard@linaro.org> wrote:
> rtc_time_to_tm() and rtc_tm_to_time() are deprecated because they
> rely on 32bits variables and that will make rtc break in y2038/2016.
> Stop using those two functions to safer 64bits ones.
>
> Signed-off-by: Benjamin Gaignard <benjamin.gaignard@linaro.org>
> CC: Michael Chan <michael.chan@broadcom.com>
> CC: netdev@vger.kernel.org
> CC: linux-kernel@vger.kernel.org

Acked-by: Michael Chan <michael.chan@broadcom.com>

Thanks.
