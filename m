From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v5 13/17] dt-bindings: qca7000: rename binding
Date: Wed, 10 May 2017 10:53:24 +0200
Message-ID: <1494406408-31760-14-git-send-email-stefan.wahren@i2se.com>
References: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
Cc: Mark Rutland <mark.rutland@arm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Before we can merge the QCA7000 UART binding the document needs to be
renamed.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 .../devicetree/bindings/net/{qca-qca7000-spi.txt => qca-qca7000.txt}      | 0
 1 file changed, 0 insertions(+), 0 deletions(-)
 rename Documentation/devicetree/bindings/net/{qca-qca7000-spi.txt => qca-qca7000.txt} (100%)

diff --git a/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt b/Documentation/devicetree/bindings/net/qca-qca7000.txt
similarity index 100%
rename from Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
rename to Documentation/devicetree/bindings/net/qca-qca7000.txt
-- 
2.1.4
