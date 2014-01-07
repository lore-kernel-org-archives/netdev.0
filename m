From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 3/3] ARM: shmobile: genmai: Enable r7s72100-ether
Date: Wed, 08 Jan 2014 02:13:47 +0400
Message-ID: <52CC7C1B.20807@cogentembedded.com>
References: <1389061635-4083-1-git-send-email-horms+renesas@verge.net.au> <1389061635-4083-4-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms+renesas@verge.net.au>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1389061635-4083-4-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 07-01-2014 6:27, Simon Horman wrote:

    You've removed RFC but still haven't signed off. :-)

> ---
> v2
> * As suggested by Magnus Damm and Sergei Shtylyov
>    - r7s72100 ethernet is not gigabit so do not refer to it as such

> * As suggested by Sergei Shtylyov
>    - set no_ether_link as there is no LINK signal documented
>      in the manual

    I'm OK with the patch, you can add my Acked-by.

WBR, Sergei

