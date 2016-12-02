From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 1/2] net: stmmac: avoid Camelcase naming
Date: Fri, 2 Dec 2016 10:25:30 +0100
Message-ID: <adf5823f-97b4-a9d5-19b5-8b4ef63f52a4@st.com>
References: <1480605581-13350-1-git-send-email-clabbe.montjoie@gmail.com>
 <83a25cf8-907b-074e-754c-faa9e641c896@st.com> <20161202085846.GB20128@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <alexandre.torgue@st.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161202085846.GB20128@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/2/2016 9:58 AM, Corentin Labbe wrote:
> On Fri, Dec 02, 2016 at 09:44:48AM +0100, Giuseppe CAVALLARO wrote:
>> Hello Corentin
>>
>> patches look ok, I just wonder if you tested it in case of
>> the stmmac is connected to a transceiver. Let me consider it
>> a critical part of the driver to properly work.
>>
>> Regards
>> Peppe
>>
>
> I tested it on a Cubieboard 2 (dwmac-sunxi).
> What do you mean by "connected to a transceiver" ? an external PHY ?

yes an external PHY. AFAIK, users have, sometime, a switch
with fixed link enabled.

Thx for your support and patches

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

>
> Regards
>
