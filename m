From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Re: [PATCH net-next 0/4]  Allow bridge to function in non-promisc mode
Date: Wed, 13 Mar 2013 10:22:23 +0400
Message-ID: <473541363155743@web2d.yandex.ru>
References: <1363139126-13396-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>
To: Vlad Yasevich <vyasevic@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward1.mail.yandex.net ([77.88.46.6]:52488 "EHLO
	forward1.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755118Ab3CMG35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 02:29:57 -0400
In-Reply-To: <1363139126-13396-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



13.03.2013, 05:45, "Vlad Yasevich" <vyasevic@redhat.com>:

> The series adds an ability for the bridge to function in non-promiscuous mode.

What is the practical applications for such setup? In other words,
in which cases I would want to put bridge into non-promiscuous
mode and specify some uplink ports?

-- 
wbr, Oleg.

"Anarchy is about taking complete responsibility for yourself."
 Alan Moore.
