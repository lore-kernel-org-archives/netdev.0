From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] rtl8xxxu: mark expected switch fall-throughs
Date: Wed, 11 Oct 2017 11:41:49 +0300
Message-ID: <87o9peqdo2.fsf@kamboji.qca.qualcomm.com>
References: <20171010193027.GA23108@embeddedor.com>
        <5f5f0f54-d901-90be-9025-0a1c4b909368@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jes Sorensen <jes.sorensen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5f5f0f54-d901-90be-9025-0a1c4b909368@gmail.com> (Jes Sorensen's
        message of "Tue, 10 Oct 2017 15:35:10 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jes Sorensen <jes.sorensen@gmail.com> writes:

> On 10/10/2017 03:30 PM, Gustavo A. R. Silva wrote:
>> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
>> where we are expecting to fall through.
>
> While this isn't harmful, to me this looks like pointless patch churn
> for zero gain and it's just ugly.

In general I find it useful to mark fall through cases. And it's just a
comment with two words, so they cannot hurt your eyes that much.

-- 
Kalle Valo
