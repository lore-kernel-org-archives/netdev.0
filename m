From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Wed, 6 Sep 2017 16:37:07 -0700
Message-ID: <CA+55aFwzYm5o98ZpbC1hOGfkcbYQaucuqZN6qB1f7_qW2CjVpQ@mail.gmail.com>
References: <20170905.214143.826912481689443792.davem@davemloft.net> <CA+55aFw0KNTKFrRHk5hthDGTGgL9BGt9G=x_m9Tz7m_-pN+NoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Intel Linux Wireless <linuxwifi@intel.com>,
        Linux Wireless List <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Luca Coelho <luciano.coelho@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFw0KNTKFrRHk5hthDGTGgL9BGt9G=x_m9Tz7m_-pN+NoA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 6, 2017 at 4:27 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> The firmware is iwlwifi-8000C-28.ucode from
> iwl7260-firmware-25.30.13.0-75.fc26.noarch, and the kernel reports
>
>   iwlwifi 0000:3a:00.0: loaded firmware version 27.455470.0 op_mode iwlmvm

And when I said "iwlwifi-8000C-28.ucode" I obviously meant
"iwlwifi-8000C-27.ucode".

At least it was _hopefully_ obvious from that "27" in the actual
version number it reports.

            Linus
