From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH] net/wireless: Fix 'multiple blank lines' check
Date: Tue, 31 May 2016 23:01:06 +1000
Message-ID: <CAGRGNgWXq076qnu9ucFR9d60i2BzMcREd8AeTrDMmC33kEeQ=A@mail.gmail.com>
References: <20160531055858.GA32239@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160531055858.GA32239@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

On Tue, May 31, 2016 at 3:58 PM, Kirtika Ruchandani
<kirtika.ruchandani@gmail.com> wrote:
> This patch fixes the checkpatch.pl check "Please don't use multiple
> blank lines" for all files in net/wireless, except nl80211.c which
> is covered in a separated patch.
>
> Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>

Looks right to me.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

> ---
>  net/wireless/ap.c          | 1 -
>  net/wireless/chan.c        | 3 ---
>  net/wireless/core.h        | 2 --
>  net/wireless/ibss.c        | 1 -
>  net/wireless/mlme.c        | 2 --
>  net/wireless/radiotap.c    | 2 --
>  net/wireless/rdev-ops.h    | 2 --
>  net/wireless/reg.c         | 3 ---
>  net/wireless/scan.c        | 1 -
>  net/wireless/sme.c         | 1 -
>  net/wireless/util.c        | 2 --
>  net/wireless/wext-compat.c | 3 ---
>  net/wireless/wext-compat.h | 2 --
>  net/wireless/wext-core.c   | 6 ------
>  net/wireless/wext-proc.c   | 1 -
>  net/wireless/wext-sme.c    | 1 -
>  16 files changed, 33 deletions(-)

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
