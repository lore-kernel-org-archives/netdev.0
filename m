From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: RE: Multicast problem
Date: Tue, 16 Oct 2007 20:54:06 +0200
Message-ID: <002601c81025$ee0af8f0$04ac10ac@Jocke>
References: <OFB45E9AE1.F95FB289-ON88257376.005D25C3-88257376.005DB70D@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Netdev'" <netdev@vger.kernel.org>
To: "'David Stevens'" <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:44398 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933442AbXJPSyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 14:54:11 -0400
In-Reply-To: <OFB45E9AE1.F95FB289-ON88257376.005D25C3-88257376.005DB70D@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Stevens [mailto:dlstevens@us.ibm.com] 
> Sent: den 16 oktober 2007 19:05
> To: joakim.tjernlund@transmode.se
> Cc: Netdev
> Subject: Re: Multicast problem
> 
> If you have icmp_echo_ignore_broadcasts set to 1, it won't respond to
> multicasts. That should be all you need to do for 224.0.0.1.

hmm maybe I misunderstand here, but the we are trying to make OSPF work
in 2.6 and the problem appears to be that our board does not pick up
multicasts.
Is icmp_echo_ignore_broadcasts=0 required to make OSPF work in 2.6?

 Jocke

