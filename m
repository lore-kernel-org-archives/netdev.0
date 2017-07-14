From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH 1/2] dt-bindings: net: Add bindings for National
 Instruments XGE netdev
Date: Fri, 14 Jul 2017 00:33:16 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15BE5A6E@cnshjmbx02>
References: <1499980909-11702-1-git-send-email-mdf@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "mark.rutland@arm.com" <mark.rutland@arm.com>,
        "robh+dt@kernel.org" <robh+dt@kernel.org>
To: Moritz Fischer <mdf@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:43087 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752045AbdGNAdU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 20:33:20 -0400
In-Reply-To: <1499980909-11702-1-git-send-email-mdf@kernel.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Moritz Fischer
> Sent: Friday, July 14, 2017 5:22 AM
> To: netdev@vger.kernel.org
> Cc: devicetree@vger.kernel.org; linux-kernel@vger.kernel.org;
> davem@davemloft.net; mark.rutland@arm.com; robh+dt@kernel.org; Moritz
> Fischer
> Subject: [PATCH 1/2] dt-bindings: net: Add bindings for National Instruments
> XGE netdev
> 
> This adds bindings for the NI XGE 1G/10G network device.
> 
> Signed-off-by: Moritz Fischer <mdf@kernel.org>
> ---
>  Documentation/devicetree/bindings/net/nixge.c | 32
> +++++++++++++++++++++++++++
>  1 file changed, 32 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/nixge.c

It should be a text file, nixge.txt

> 
> diff --git a/Documentation/devicetree/bindings/net/nixge.c
> b/Documentation/devicetree/bindings/net/nixge.c
> new file mode 100644
> index 0000000..9fff5a7
