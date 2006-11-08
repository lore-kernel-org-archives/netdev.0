From: Roger While <simrw@sim-basis.de>
Subject: Re. Please pull 'upstream' branch of wireless-2.6
Date: Wed, 08 Nov 2006 18:27:54 +0100
Message-ID: <6.1.1.1.2.20061108182728.02b11300@192.168.6.12>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout11.sul.t-online.com ([194.25.134.85]:44675 "EHLO
	mailout11.sul.t-online.com") by vger.kernel.org with ESMTP
	id S1754606AbWKHR2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 12:28:24 -0500
Received: from simrog.sim-basis.de (simrog [192.168.6.50])
	by simlinux.site (8.13.3/8.13.3/SuSE Linux 0.7) with ESMTP id kA8HRu06008805
	for <netdev@vger.kernel.org>; Wed, 8 Nov 2006 18:28:00 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John, you just broke a considerable number of prism54 users.
It is NOT an error if the MWI set fails. This is just a
performance tweak and has NO effect on the driver working.

Roger While


