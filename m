From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v1 2/5] Documentation: dts: Update section header for
 APM X-Gene
Date: Wed, 24 Sep 2014 17:22:24 +0400
Message-ID: <5422C590.1080006@cogentembedded.com>
References: <1411530688-2939-1-git-send-email-isubramanian@apm.com> <1411530688-2939-3-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kchudgar@apm.com, patches@apm.com
To: Iyappan Subramanian <isubramanian@apm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:34736 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbaIXNWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 09:22:46 -0400
Received: by mail-lb0-f169.google.com with SMTP id b12so10723765lbj.28
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 06:22:44 -0700 (PDT)
In-Reply-To: <1411530688-2939-3-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/24/2014 7:51 AM, Iyappan Subramanian wrote:

> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> ---
>   Documentation/devicetree/bindings/net/apm-xgene-enet.txt | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)

> diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
> index ebcad25..60a7857 100644
> --- a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
> +++ b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
[...]
> @@ -15,6 +15,8 @@ Required properties:
>   - clocks: Reference to the clock entry.
>   - local-mac-address: MAC address assigned to this device
>   - phy-connection-type: Interface type between ethernet device and PHY device
> +
> +Required properties for ethernet interfaces that has external PHY:

    s/has/have/.

WBR, Sergei
