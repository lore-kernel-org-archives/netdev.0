From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 0/2] rfkill
Date: Tue, 8 Aug 2006 16:30:09 +0200
Message-ID: <200608081630.09830.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:20693 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964912AbWHHOaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 10:30:39 -0400
Received: by nf-out-0910.google.com with SMTP id q29so188381nfc
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2006 07:30:38 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

With the previous Request for comments for rfkill it seemed
most people did not have any objectiosn against rfkill.
So now I wish to submit rfkill to wireless-dev. :)

First patch will add rfkill to input/misc/ while the second
patch will make rt2x00 use rfkill.

Ivo
