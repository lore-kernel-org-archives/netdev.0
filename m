From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/3] net: dt-bindings: Document the new Meson8b and GXBB
 DWMAC bindings
Date: Tue, 16 Aug 2016 09:25:40 -0500
Message-ID: <20160816142540.GA1332@rob-hp-laptop>
References: <20160625165013.15917-1-martin.blumenstingl@googlemail.com>
 <20160815164100.27766-1-martin.blumenstingl@googlemail.com>
 <20160815164100.27766-2-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-amlogic@lists.infradead.org, khilman@baylibre.com,
	carlo@caione.org, mturquette@baylibre.com, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, mark.rutland@arm.com,
	catalin.marinas@arm.com, will.deacon@arm.com,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:32955 "EHLO
	mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306AbcHPOZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 10:25:42 -0400
Content-Disposition: inline
In-Reply-To: <20160815164100.27766-2-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 15, 2016 at 06:40:58PM +0200, Martin Blumenstingl wrote:
> This patch adds the documentation for the DWMAC ethernet controller
> found in Amlogic Meson 8b (S805) and GXBB (S905) SoCs.
> The main difference between the Meson6 glue is that different registers
> (with different layout) are used.
> 
> Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
> ---
>  .../devicetree/bindings/net/meson-dwmac.txt        | 43 ++++++++++++++++++----
>  1 file changed, 35 insertions(+), 8 deletions(-)

Acked-by: Rob Herring <robh@kernel.org>
