From: =?ISO-8859-1?Q?Ra=FAl_Hern=E1ndez?= <rauhersu@gmail.com>
Subject: ip monitoring
Date: Thu, 22 Jan 2009 01:18:35 +0100
Message-ID: <3f847c820901211618p476f3b71kbc994680d4a0a2e8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:24453 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754569AbZAVASh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 19:18:37 -0500
Received: by fg-out-1718.google.com with SMTP id 19so1958543fgg.17
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2009 16:18:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

Just a quick question regarding ip monitoring: I am trying to develop
a user space app which must be aware of changes related to ip
management and link status (up, down, this-ip-has-been added,..). So
far, I am trying to avoid polling the link/ip to notice these changes
as I would like to be notified asynchronously.

Is there any API/quick fix for user space apps to get that (I am
trying to avoid any kernel development as well) ?

Thx!

Best regards,
Raul

--
Los viajes son en la juventud una parte de educaci=F3n y, en la vejez,
una parte de experiencia -- Francis Bacon
