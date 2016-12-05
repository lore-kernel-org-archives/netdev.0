From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH net-next v4 2/4] dt-bindings: net: add EEE capability
 constants
Date: Mon, 5 Dec 2016 08:39:42 -0600
Message-ID: <20161205143942.f3w6nmp3jvmrk5es@rob-hp-laptop>
References: <1480348229-25672-1-git-send-email-jbrunet@baylibre.com>
 <1480348229-25672-3-git-send-email-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>, Andrew Lunn <andrew@lunn.ch>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Yegor Yefremov <yegorslists@googlemail.com>,
        Andreas =?iso-8859-1?Q?F=E4rber?= <afaerber@suse.de>
To: Jerome Brunet <jbrunet@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1480348229-25672-3-git-send-email-jbrunet@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 04:50:26PM +0100, Jerome Brunet wrote:
> Signed-off-by: Jerome Brunet <jbrunet@baylibre.com>
> Tested-by: Yegor Yefremov <yegorslists@googlemail.com>
> Tested-by: Andreas Färber <afaerber@suse.de>
> Tested-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  include/dt-bindings/net/mdio.h | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
>  create mode 100644 include/dt-bindings/net/mdio.h

Seems changes are wanted on this, but patches 2 and 3 should be 
combined. The header is part of the binding doc.

Rob
