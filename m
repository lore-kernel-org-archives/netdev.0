From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] MAINTAINERS: Remove myself from PA Semi entries
Date: Tue, 13 Sep 2016 14:48:38 -0700
Message-ID: <1473803318-25197-1-git-send-email-olof@lixom.net>
Cc: netdev@vger.kernel.org, linux-i2c@vger.kernel.org,
        davem@davemloft.net, jdelvare@suse.com,
        Olof Johansson <olof@lixom.net>
To: Michael Ellerman <mpe@ellerman.id.au>
Return-path: <linux-i2c-owner@vger.kernel.org>
Sender: linux-i2c-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The platform is old, very few users and I lack bandwidth to keep after
it these days.

Mark the base platform as well as the drivers as orphans, patches have
been flowing through the fallback maintainers for a while already.

Signed-off-by: Olof Johansson <olof@lixom.net>
---

Jean, Dave,

I was hoping to have Michael merge this since the bulk of the platform is under him,
cc:ing you mostly to be aware that I am orphaning a driver in your subsystems.


Thanks,

-Olof

 MAINTAINERS | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index d8e81b1..411f4f7 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7155,9 +7155,8 @@ F:	arch/powerpc/platforms/83xx/
 F:	arch/powerpc/platforms/85xx/
 
 LINUX FOR POWERPC PA SEMI PWRFICIENT
-M:	Olof Johansson <olof@lixom.net>
 L:	linuxppc-dev@lists.ozlabs.org
-S:	Maintained
+S:	Orphan
 F:	arch/powerpc/platforms/pasemi/
 F:	drivers/*/*pasemi*
 F:	drivers/*/*/*pasemi*
@@ -8849,15 +8848,13 @@ S:	Maintained
 F:	drivers/net/wireless/intersil/p54/
 
 PA SEMI ETHERNET DRIVER
-M:	Olof Johansson <olof@lixom.net>
 L:	netdev@vger.kernel.org
-S:	Maintained
+S:	Orphan
 F:	drivers/net/ethernet/pasemi/*
 
 PA SEMI SMBUS DRIVER
-M:	Olof Johansson <olof@lixom.net>
 L:	linux-i2c@vger.kernel.org
-S:	Maintained
+S:	Orphan
 F:	drivers/i2c/busses/i2c-pasemi.c
 
 PADATA PARALLEL EXECUTION MECHANISM
-- 
2.8.0.rc3.29.gb552ff8
