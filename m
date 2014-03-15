From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/3] Beautify 'sh_eth' driver's messages
Date: Sat, 15 Mar 2014 03:24:13 +0300
Message-ID: <53239DAD.80003@cogentembedded.com>
References: <201403150321.47674.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201403150321.47674.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/15/2014 03:21 AM, Sergei Shtylyov wrote:

> This patchset converts te driver to using netdev_*() and netif_*() to print out
> its messages whenever possible.

    Oops, forgot to mention it's against 'net-next.git' repo and the fix I've 
just posted.

> [1/3] sh_eth: convert pr_*() to netdev_*() calls
> [2/3] sh_eth: convert dev_*() to netdev_*() calls
> [3/3] sh_eth: fold netif_msg_*() and dev_*() calls into netif_*() invocations

WBR, Sergei

