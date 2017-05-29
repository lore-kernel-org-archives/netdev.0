From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v8 net-next 14/17] dt-bindings: qca7000: rename binding
Date: Mon, 29 May 2017 13:57:22 +0200
Message-ID: <1496059045-13572-15-git-send-email-stefan.wahren@i2se.com>
References: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Jakub Kicinski <kubakici@wp.pl>, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Before we can merge the QCA7000 UART binding the document needs to be
renamed.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 .../devicetree/bindings/net/{qca-qca7000-spi.txt => qca,qca7000.txt}      | 0
 1 file changed, 0 insertions(+), 0 deletions(-)
 rename Documentation/devicetree/bindings/net/{qca-qca7000-spi.txt => qca,qca7000.txt} (100%)

diff --git a/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt b/Documentation/devicetree/bindings/net/qca,qca7000.txt
similarity index 100%
rename from Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
rename to Documentation/devicetree/bindings/net/qca,qca7000.txt
-- 
2.1.4
