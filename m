From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 14/15] net: wireless: ath: Remove unneeded variable ret
 returning 0
Date: Thu, 22 Oct 2015 21:56:46 +0300
Message-ID: <5629316E.60106@cogentembedded.com>
References: <1445539670-4018-1-git-send-email-punitvara@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mickflemm@gmail.com, mcgrof@do-not-panic.com, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Punit Vara <punitvara@gmail.com>, jirislaby@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445539670-4018-1-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/2015 09:47 PM, Punit Vara wrote:

> Remove black line suggested by Sergei

    Such kind of comments should be under the --- tear line.

>
> This patch is to the ath5k/eeprom.c that fixes up warning caught by
> coccicheck:
>
> Unneeded variable: "ret". Return "0" on line 980
>
> Remove unneeded variable ret created to return zero.
>
> Signed-off-by: Punit Vara <punitvara@gmail.com>
[...]

MBR, Sergei
