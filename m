From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 2/5] wlcore: Delete an unnecessary check statement in wlcore_set_beacon_template()
Date: Tue, 31 Oct 2017 00:26:16 +1100
Message-ID: <CAGRGNgWFgg5oyRcgP6mp--oF6VPcD1k13SyKmmK3cc8KPC05BQ@mail.gmail.com>
References: <dc2b8a7c-b4a9-2f92-12b4-a1d0d6911d7c@users.sourceforge.net> <ccb3f6ab-3c39-9c34-518f-f7f36615930b@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Eyal Reizer <eyalr@ti.com>, Iain Hunter <drhunter95@gmail.com>,
        James Minor <james.minor@ni.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Maxim Altshul <maxim.altshul@ti.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors <kernel-janitors@vger.kernel.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ccb3f6ab-3c39-9c34-518f-f7f36615930b@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 30, 2017 at 7:12 AM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sun, 29 Oct 2017 19:45:07 +0100
>
> A goto statement jumped to a target which followed a condition check
> immediately without the specification of useful actions between.
> Thus remove such unnecessary source code at the end of this function.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Looks good to me.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
