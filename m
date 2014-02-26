From: Neil Jerram <Neil.Jerram@metaswitch.com>
Subject: [PATCH net-next 0/1] net: Add doc on how SKBs work
Date: Wed, 26 Feb 2014 12:10:58 +0000
Message-ID: <1393416659-10868-1-git-send-email-Neil.Jerram@metaswitch.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Neil Jerram <Neil.Jerram@metaswitch.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from enfirhets1.metaswitch.com ([192.91.191.166]:10829 "EHLO
	ENFIRHETS1.metaswitch.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbaBZMLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 07:11:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm ramping up on Linux networking and found the material at
http://vger.kernel.org/~davem/skb_data.html very useful.  Therefore
here is a patch to copy that into a Documentation/networking file in
the Linux tree.

Is this kind of thing welcome?  If it is, I'm aware that:

- some of the details are out of date

- more material would be useful on other pointers into the data area,
  such as the MAC and network headers

and would propose to work on addressing those in subsequent changes.

Regards,
    Neil


Neil Jerram (1):
  net: Add doc on how SKBs work

 Documentation/networking/00-INDEX     |    2 +
 Documentation/networking/skb_data.txt |  385 +++++++++++++++++++++++++++++++++
 2 files changed, 387 insertions(+)
 create mode 100644 Documentation/networking/skb_data.txt

-- 
1.7.10.4
