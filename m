From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 3/24] RT2x00: Merge rt2x00_pci and rt2x00_usb
Date: Wed, 26 Jul 2006 19:04:39 +0200
Message-ID: <200607261904.39680.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:5025 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751707AbWGZRHX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 13:07:23 -0400
Received: by nf-out-0910.google.com with SMTP id o25so812601nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:07:22 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

rt2x00_pci and rt2x00_usb are for 99% equal,
the only difference they have are not worth the duplicate code.
Merge the structures into rt2x00_dev.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

http://www.mendiosus.nl/rt2x00/03_rt2x00_pciusb_dev.diff
