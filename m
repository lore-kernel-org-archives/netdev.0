From: "Reinin Oyama" <lenin@hasiru.net>
Subject: [PACTH 1/1] drivers/net/usb: AX88178 100Mbps problem
Date: Mon, 28 Jan 2008 22:32:42 +0900
Message-ID: <479DD97A.8020307@hasiru.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070101090804050304030205"
Cc: "David Hollis" <dhollis@davehollis.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ml1.lenin.jp ([219.166.53.194]:61161 "HELO ml.hasiru.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755173AbYA1NkG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 08:40:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070101090804050304030205
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Asix 88178 does not work under 100Mbps connection.
This patch correct the problem.
kernel version: 2.6.24

--------------070101090804050304030205
Content-Type: application/gzip;
 name="asix_driver_patch.gz"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="asix_driver_patch.gz"

H4sICInDnUcAA2FzaXhfZHJpdmVyX3BhdGNoAIWQa2vCMBSGP9tfcT6JUlPTzktXpyizu7C5
yVQYjFF6OdZgbzSpU/DHL50ThIkL+ZC8ec/znpOP6Wh++/AJLmdbKLgHIQtdjwlIUHyl+Rrc
IM0E5qBTOvEyDlmeehHGyoyFCQYkXS6Jt7PgDVnCEnjdubELNxHKy3AloXmhSdJAIYRAxJJi
SwytoxmtZpCzDea8KV+bMrdZNqD5FYNSk1CdGG2gXattWlddjR4XqPSaUkVV1QPrX4gJettq
dayW+QcyHALR5VANXSrHgxS5cAXzgSUC3K1p6l3TkVlrJ0eOosZFXvii/CgFFKjEjDn+Cv21
E2PA3Fo1wA0ZSLUButz13q8HxUqkaeSEJePEVEU/DqSLVOI0QOjD6P0QObHHj4uJM7bvRovn
eU9RLxtgLx+Omv1y+9T7aY8toVYmaDxDDKDfh9nUtseOnJbWZegBuu+fFN9PzrDU885yOow4
woWcuvScKZ7OjsXKN+xQUxmCAgAA
--------------070101090804050304030205--
