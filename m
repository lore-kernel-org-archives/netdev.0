From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH] realtek: Add switch variable to 'switch case not processed' messages
Date: Sat, 24 Sep 2016 16:02:02 -0400
Message-ID: <wrfjd1jtt6bp.fsf@redhat.com>
References: <1474654333.1849.5.camel@perches.com>
        <d091f73a6adf3bdaa09ab0399c22a9fdfe9b188c.1474654979.git.joe@perches.com>
        <f98d2cf1-802a-93c1-b219-ec45aa417940@lwfinger.net>
        <1474657363.1849.9.camel@perches.com>
        <20160924175555.01cae6dd@endymion>
        <1474733754.23838.3.camel@perches.com>
        <49094659-662d-a902-6740-ea3d1fea6660@lwfinger.net>
        <1474738358.23838.11.camel@perches.com>
        <cef6d8da-c390-f435-7a5e-d294dfbebbfb@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Joe Perches <joe@perches.com>, Jean Delvare <jdelvare@suse.de>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cef6d8da-c390-f435-7a5e-d294dfbebbfb@lwfinger.net> (Larry
        Finger's message of "Sat, 24 Sep 2016 14:06:29 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry Finger <Larry.Finger@lwfinger.net> writes:
> On 09/24/2016 12:32 PM, Joe Perches wrote:
>> Is there any value in that or is Jes' work going to make
>> doing any or all of this unnecessary and futile?
>
> That is not yet determined. The only driver that is to be replaced at
> this point is rtl8192cu. Jes only has USB I/O for his driver. We are
> looking at adding SDIO, and once that is done, PCI should be possible.

If someone else wants to address PCI then it could happen quite soon,
but at the current schedule I don't see PCI happen in my driver for at
least a year, probably more.

If you can reduce the size of rtlwifi in the mean time that probably
isn't going to upset a lot of people.

Jes
