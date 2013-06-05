From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 0/8] sh_eth: deal with #ifdef'fery
Date: Thu, 06 Jun 2013 02:50:32 +0400
Message-ID: <51AFC0B8.2070902@cogentembedded.com>
References: <201306060106.51082.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306060106.51082.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/06/2013 01:06 AM, Sergei Shtylyov wrote:
> Hello.
>
>     This series deals mostly with excess #ifdef'fery in the 'sh_eth' driver.
> It doesn't yet get rid of all the #ifdef'fery but that's a matter of another
> patchset. The last patch (it was almost in the middle of the series before),
> contrarywise, adds one missing #ifdef...

    Gah, forgot to note that the patchset is against the 'net-next' repo.
I still suck at writing cover letters. :-/

WBR, Sergei

