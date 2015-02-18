From: Cong Wang <cwang@twopensource.com>
Subject: Why do we use RX queue mapping for TX?
Date: Wed, 18 Feb 2015 13:09:21 -0800
Message-ID: <CAHA+R7MXF-KHZ3aeBwwshSYDswKwrjhbMJQ=+Hfj3gZJq70dXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:34843 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbbBRVJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 16:09:21 -0500
Received: by iecrl12 with SMTP id rl12so4633362iec.2
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 13:09:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David


With regarding to the following commit:
