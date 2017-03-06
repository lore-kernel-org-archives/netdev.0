From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 10/26] brcmsmac: reindent split functions
Date: Mon, 06 Mar 2017 18:24:16 +0200
Message-ID: <87tw7674r3.fsf@purkki.adurom.net>
References: <20170302163834.2273519-1-arnd@arndb.de>
        <20170302163834.2273519-11-arnd@arndb.de>
        <c18494f1-1a21-c1e5-31db-bef78abe172f@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>
To: Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <c18494f1-1a21-c1e5-31db-bef78abe172f@broadcom.com> (Arend Van
        Spriel's message of "Mon, 6 Mar 2017 10:33:34 +0100")
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arend Van Spriel <arend.vanspriel@broadcom.com> writes:

> On 2-3-2017 17:38, Arnd Bergmann wrote:
>> In the previous commit I left the indentation alone to help reviewing
>> the patch, this one now runs the three new functions through 'indent -kr -8'
>> with some manual fixups to avoid silliness.
>> 
>> No changes other than whitespace are intended here.
>
> Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> ---
>>  .../broadcom/brcm80211/brcmsmac/phy/phy_n.c        | 1507 +++++++++-----------
>>  1 file changed, 697 insertions(+), 810 deletions(-)
>> 

Arend, please edit your quotes. Leaving 1000 lines of unnecessary quotes
in your reply makes my use of patchwork horrible:

https://patchwork.kernel.org/patch/9601155/

-- 
Kalle Valo
