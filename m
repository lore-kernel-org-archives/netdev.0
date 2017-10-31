From: "Steven J. Hill" <Steven.Hill@cavium.com>
Subject: pull request: Cavium Octeon III firmware
Date: Tue, 31 Oct 2017 17:05:01 -0500
Message-ID: <5c4e2fd7-8f0c-3b6a-3bf6-c5eec9f99e1b@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-firmware@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0050.outbound.protection.outlook.com ([104.47.33.50]:13560
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753802AbdJaWFf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 18:05:35 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Would like to add firmware for our Octeon III PKI driver. Thanks.

Steve


The following changes since commit bf04291309d3169c0ad3b8db52564235bbd08e30:

  WHENCE: Add new qed firmware (2017-10-09 18:03:26 +0100)

are available in the git repository at:

  git://git.linux-mips.org/pub/scm/sjhill/linux-firmware.git master

for you to fetch changes up to 4ba60409661aae0f53e2ade1e935252846cb7ee8:

  cavium: Add firmware for Octeon III PKI. (2017-10-31 16:31:11 -0500)

----------------------------------------------------------------
Steven J. Hill (1):
      cavium: Add firmware for Octeon III PKI.

 cavium/pki-cluster.bin | Bin 0 -> 7488 bytes
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 cavium/pki-cluster.bin
