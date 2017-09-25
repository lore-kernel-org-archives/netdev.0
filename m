From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] brcm80211: make const array ucode_ofdm_rates static, reduces object code size
Date: Mon, 25 Sep 2017 07:20:17 +0300
Message-ID: <87poaf76ke.fsf@kamboji.qca.qualcomm.com>
References: <20170922140316.12768-1-colin.king@canonical.com>
        <96caf646-a43c-9b78-a4a9-2becf7e74125@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Colin King <colin.king@canonical.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Chi-Hsien Lin <chi-hsien.lin@cypress.com>,
        Wright Feng <wright.feng@cypress.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com,
        brcm80211-dev-list@cypress.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arend van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <96caf646-a43c-9b78-a4a9-2becf7e74125@broadcom.com> (Arend van
        Spriel's message of "Fri, 22 Sep 2017 18:51:43 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arend van Spriel <arend.vanspriel@broadcom.com> writes:

> Please use 'brcmsmac:' as prefix instead of 'brcm80211:'.

I can fix that.

-- 
Kalle Valo
