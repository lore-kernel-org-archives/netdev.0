From: Ismail =?utf-8?q?D=C3=B6nmez?= <ismail@pardus.org.tr>
Subject: Re: Netfilter: kernel panic with REDIRECT target. (2.6.23 and 2.6.23.8)
Date: Sun, 18 Nov 2007 21:31:38 +0200
Message-ID: <200711182131.38388.ismail@pardus.org.tr>
References: <47408BBC.6040608@unsolicited.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David <david@unsolicited.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:45693 "EHLO uludag.org.tr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751838AbXKRTbj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2007 14:31:39 -0500
In-Reply-To: <47408BBC.6040608@unsolicited.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sunday 18 November 2007 Tarihinde 21:00:12 yazm=C4=B1=C5=9Ft=C4=B1:
> I'm (very) far from being firewall configuration expert, but I'm seei=
ng
> a consistent kernel panic when the following rule is triggered.
>
>     iptables -t nat -A PREROUTING -j REDIRECT -i eth2 -p udp --dport
> 5061 --to-ports 5060
>
> (I'm trying to redirect an alternate port to a SIP server)
>
> Am I just being very stupid, or is there something I'm not seeing her=
e?

Also post the kernel panic log.


--=20
=46aith is believing what you know isn't so -- Mark Twain
