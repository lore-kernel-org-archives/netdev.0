From: Michael Heimpold <mhei-Z/Lg1yOAjpkb1SvskN2V4Q@public.gmane.org>
Subject: Re: [PATCH v5 13/17] dt-bindings: qca7000: rename binding
Date: Thu, 11 May 2017 21:48:02 +0200
Message-ID: <166063028.gdG7XIniBq@kerker>
References: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com> <1494406408-31760-14-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1494406408-31760-14-git-send-email-stefan.wahren-eS4NqCHxEME@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Am Mittwoch, 10. Mai 2017, 10:53:24 CEST schrieb Stefan Wahren:
> Before we can merge the QCA7000 UART binding the document needs to be
> renamed.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
> ---
>  .../devicetree/bindings/net/{qca-qca7000-spi.txt => qca-qca7000.txt}      |
> 0 1 file changed, 0 insertions(+), 0 deletions(-)
>  rename Documentation/devicetree/bindings/net/{qca-qca7000-spi.txt =>
> qca-qca7000.txt} (100%)
> 
> diff --git a/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
> b/Documentation/devicetree/bindings/net/qca-qca7000.txt similarity index
> 100%
> rename from Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
> rename to Documentation/devicetree/bindings/net/qca-qca7000.txt

I was told here [1], that it is prefered when the filename matchs the
compatible string, so using "qca,qca7000.txt" should be better.

Regards,
Michael


[1]
https://www.spinics.net/lists/devicetree/msg124088.html
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
