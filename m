From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [IPV4] Remove unused member of dst_entry
Date: Sun, 6 Jan 2008 12:15:35 +0200
Message-ID: <eb3ff54b0801060215g55cf862ja793400f060b9e34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_8410_8382154.1199614535366"
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:40592 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbYAFKPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2008 05:15:38 -0500
Received: by fg-out-1718.google.com with SMTP id e21so4021834fga.17
        for <netdev@vger.kernel.org>; Sun, 06 Jan 2008 02:15:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_8410_8382154.1199614535366
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
	
  The info placeholder member of dst_entry seems to be unused in the
network stack.
	
Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_8410_8382154.1199614535366
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fb3f2om20
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2RzdC5oIGIvaW5jbHVkZS9uZXQvZHN0LmgKaW5kZXgg
MzE0NjhjOS4uZTAzZWEwYyAxMDA2NDQKLS0tIGEvaW5jbHVkZS9uZXQvZHN0LmgKKysrIGIvaW5j
bHVkZS9uZXQvZHN0LmgKQEAgLTgwLDcgKzgwLDYgQEAgc3RydWN0IGRzdF9lbnRyeQogCQlzdHJ1
Y3QgcnQ2X2luZm8gICAqcnQ2X25leHQ7CiAJCXN0cnVjdCBkbl9yb3V0ZSAgKmRuX25leHQ7CiAJ
fTsKLQljaGFyCQkJaW5mb1swXTsKIH07CiAKIAo=
------=_Part_8410_8382154.1199614535366--
