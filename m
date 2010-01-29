From: Susant Sahani <ssahani@gmail.com>
Subject: NF_STOLEN and reinsert in to IP stack
Date: Fri, 29 Jan 2010 18:08:55 +0530
Message-ID: <d81115a61001290438t3cc3f657le11b68a9786090be@mail.gmail.com>
References: <d81115a61001290434x740c7381v6929d6aea1d354dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:62274 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853Ab0A2MjP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 07:39:15 -0500
Received: by pwi21 with SMTP id 21so1316623pwi.21
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 04:39:15 -0800 (PST)
In-Reply-To: <d81115a61001290434x740c7381v6929d6aea1d354dd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi,
 =A0=A0=A0=A0=A0=A0=A0 How to reinsert a packet into IP stack after usi=
ng NF_STOLEN. If I
 do a nf_reinject it crashes .

 Thanks,
 Susant
