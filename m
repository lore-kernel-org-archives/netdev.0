From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: bugfix: wireless bug causing working setups to loose net connectivity
Date: Mon, 21 Sep 2009 20:35:50 +0200
Message-ID: <200909212035.50592.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:34607 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbZIUSfv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 14:35:51 -0400
Received: by bwz6 with SMTP id 6so2134183bwz.37
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2009 11:35:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Could=20
http://marc.info/?l=3Dlinux-wireless&m=3D125323296617306&w=3D2
be merged without waiting for separate wireless pull request?

Currently previously working setups are no longer able to connect to AP=
 (in my=20
case WPA2PSK via wpasupplicant).

AFAIK there was some kind of policy where bugfixes that break basic=20
functionality are supposed to be merged fast to allow to actually use a=
nd test=20
git kernel.

Thanks,
--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
