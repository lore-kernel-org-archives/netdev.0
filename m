From: <Tristram.Ha@microchip.com>
Subject: [PATCH v1 RFC 1/7] Replace license with GPL
Date: Fri, 6 Oct 2017 13:32:59 -0700
Message-ID: <1507321985-15097-2-git-send-email-Tristram.Ha@microchip.com>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tristram Ha <Tristram.Ha@microchip.com>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

Replace license with GPL.

Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
---
 drivers/net/dsa/microchip/ksz_9477_reg.h | 23 ++++++++++++-----------
 drivers/net/dsa/microchip/ksz_common.c   | 23 ++++++++++++-----------
 drivers/net/dsa/microchip/ksz_priv.h     | 23 ++++++++++++-----------
 drivers/net/dsa/microchip/ksz_spi.c      | 23 ++++++++++++-----------
 4 files changed, 48 insertions(+), 44 deletions(-)

diff --git a/drivers/net/dsa/microchip/ksz_9477_reg.h b/drivers/net/dsa/microchip/ksz_9477_reg.h
index 6aa6752..26a0e4b 100644
--- a/drivers/net/dsa/microchip/ksz_9477_reg.h
+++ b/drivers/net/dsa/microchip/ksz_9477_reg.h
@@ -1,19 +1,20 @@
 /*
  * Microchip KSZ9477 register definitions
  *
- * Copyright (C) 2017
+ * Copyright (C) 2017 Microchip Technology Inc.
  *
- * Permission to use, copy, modify, and/or distribute this software for any
- * purpose with or without fee is hereby granted, provided that the above
- * copyright notice and this permission notice appear in all copies.
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
  *
- * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
- * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
- * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
- * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
- * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
- * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
- * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef __KSZ9477_REGS_H
diff --git a/drivers/net/dsa/microchip/ksz_common.c b/drivers/net/dsa/microchip/ksz_common.c
index 56cd6d3..685dafd 100644
--- a/drivers/net/dsa/microchip/ksz_common.c
+++ b/drivers/net/dsa/microchip/ksz_common.c
@@ -1,19 +1,20 @@
 /*
  * Microchip switch driver main logic
  *
- * Copyright (C) 2017
+ * Copyright (C) 2017 Microchip Technology Inc.
  *
- * Permission to use, copy, modify, and/or distribute this software for any
- * purpose with or without fee is hereby granted, provided that the above
- * copyright notice and this permission notice appear in all copies.
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
  *
- * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
- * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
- * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
- * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
- * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
- * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
- * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/delay.h>
diff --git a/drivers/net/dsa/microchip/ksz_priv.h b/drivers/net/dsa/microchip/ksz_priv.h
index 2a98dbd..d461468 100644
--- a/drivers/net/dsa/microchip/ksz_priv.h
+++ b/drivers/net/dsa/microchip/ksz_priv.h
@@ -1,19 +1,20 @@
 /*
  * Microchip KSZ series switch common definitions
  *
- * Copyright (C) 2017
+ * Copyright (C) 2017 Microchip Technology Inc.
  *
- * Permission to use, copy, modify, and/or distribute this software for any
- * purpose with or without fee is hereby granted, provided that the above
- * copyright notice and this permission notice appear in all copies.
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
  *
- * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
- * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
- * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
- * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
- * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
- * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
- * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef __KSZ_PRIV_H
diff --git a/drivers/net/dsa/microchip/ksz_spi.c b/drivers/net/dsa/microchip/ksz_spi.c
index c519469..d0d6920 100644
--- a/drivers/net/dsa/microchip/ksz_spi.c
+++ b/drivers/net/dsa/microchip/ksz_spi.c
@@ -1,19 +1,20 @@
 /*
  * Microchip KSZ series register access through SPI
  *
- * Copyright (C) 2017
+ * Copyright (C) 2017 Microchip Technology Inc.
  *
- * Permission to use, copy, modify, and/or distribute this software for any
- * purpose with or without fee is hereby granted, provided that the above
- * copyright notice and this permission notice appear in all copies.
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
  *
- * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
- * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
- * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
- * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
- * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
- * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
- * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <asm/unaligned.h>
-- 
1.9.1
