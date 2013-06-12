From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net: sh_eth: fix incorrect RX length error if
 R8A7740
Date: Wed, 12 Jun 2013 18:15:13 +0400
Message-ID: <51B88271.1030101@cogentembedded.com>
References: <51B7CFFB.7090801@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, SH-Linux <linux-sh@vger.kernel.org>
To: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <51B7CFFB.7090801@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12-06-2013 5:33, Shimoda, Yoshihiro wrote:

> This patch fixes an issue that the driver increments the "RX length error"
> on every buffer in sh_eth_rx() if the R8A7740.
> This patch also adds a description about the Receive Frame Status bits.

     Thank you.

> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> ---
>   This patch is based on the latest net-next.git.

    Since this is a fix, it should have been done against 'net.git'.

WBR, Sergei

