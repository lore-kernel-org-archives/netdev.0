From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH net-next v3 1/2] dt-bindings: net: add DT bindings for
 Socionext UniPhier AVE
Date: Fri, 27 Oct 2017 09:37:20 -0500
Message-ID: <20171027143720.foahxlhcxwm4jnq7@rob-hp-laptop>
References: <1508893679-11727-1-git-send-email-hayashi.kunihiko@socionext.com>
 <1508893679-11727-2-git-send-email-hayashi.kunihiko@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Masami Hiramatsu <masami.hiramatsu@linaro.org>,
        Jassi Brar <jaswinder.singh@linaro.org>
To: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:55583 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752713AbdJ0OhW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:37:22 -0400
Content-Disposition: inline
In-Reply-To: <1508893679-11727-2-git-send-email-hayashi.kunihiko@socionext.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 10:07:58AM +0900, Kunihiko Hayashi wrote:
> DT bindings for the AVE ethernet controller found on Socionext's
> UniPhier platforms.
> 
> Signed-off-by: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
> Signed-off-by: Jassi Brar <jaswinder.singh@linaro.org>
> ---
>  .../bindings/net/socionext,uniphier-ave4.txt       | 48 ++++++++++++++++++++++
>  1 file changed, 48 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt

Acked-by: Rob Herring <robh@kernel.org>
