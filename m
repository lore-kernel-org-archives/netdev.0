From: "Michael Chan" <mchan@broadcom.com>
Subject: A new driver for Broadcom bcm5706
Date: Fri, 20 May 2005 10:15:29 -0700
Message-ID: <1116609329.31523.16.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ffan@broadcom.com, lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, jgarzik@redhat.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A new driver bnx2 for Broadcom bcm5706 is available. Since the patch is
over 500K, I've put it on the ftp server:

ftp://Net_sys_anon@ftp1.broadcom.com/bnx2-2.patch

The patch also includes new 1000BASE-X advertisement bit definitions in
mii.h

Thanks to David Miller and Jeff Garzik for reviewing and their valuable
feedback.

Signed-off-by: Michael Chan <mchan@broadcom.com>
