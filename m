From: Sri Ram Vemulpali <sri.ram.gmu06@gmail.com>
Subject: Question on DHCP
Date: Tue, 12 Oct 2010 21:33:25 -0400
Message-ID: <AANLkTikTKL2JzmHKUrraOoNdqV1=0e_r+EuvBTgURjUz@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: linux-netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52456 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869Ab0JMBd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 21:33:26 -0400
Received: by iwn7 with SMTP id 7so24590iwn.19
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 18:33:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

   I have very basic stupid doubt. Can anyone help to resolve this.

DHCP, is used for dynamically configuring IP address, mask, MTU, DNS
domain, .... for a host. DHCP is a application layer protocol, but the
values it configures are related to IP layer. How come DHCP can
configure when its data packet in embedded in to IP datagram, which
are disparate layers. I am little confused. Please clarify. Thanks.

-- 
Regards,
Sri.
