From: Jack Byer <ftn768@gmail.com>
Subject: atl1e error messages in syslog
Date: Sun, 28 Nov 2010 18:20:40 -0600
Message-ID: <AANLkTikKb-B5RpMY0S3gbWrJ0FmzJqKmnQ1SiE+fXTZS@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jcliburn@gmail.com, chris.snook@gmail.com, jie.yang@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:32783 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754334Ab0K2AUl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 19:20:41 -0500
Received: by qyk12 with SMTP id 12so5638531qyk.19
        for <netdev@vger.kernel.org>; Sun, 28 Nov 2010 16:20:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I keep getting this in my syslog. Is it something I should be
concerned about or is it normal?

=E2=80=8BNov 28 15:10:08 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence=
 number
error (rx=3D13978) (expect=3D14539)
Nov 28 15:10:08 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:10:14 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D3653) (expect=3D4219)
Nov 28 15:10:14 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:11:12 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D41450) (expect=3D42174)
Nov 28 15:11:12 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:11:39 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D14086) (expect=3D14679)
Nov 28 15:11:39 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:11:59 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D9855) (expect=3D10367)
Nov 28 15:11:59 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:12:15 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D8292) (expect=3D8939)
Nov 28 15:12:15 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:12:19 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D1097) (expect=3D1766)
Nov 28 15:12:19 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:12:21 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D466) (expect=3D1101)
Nov 28 15:12:21 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:12:25 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D2918) (expect=3D3405)
Nov 28 15:12:25 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:12:49 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D14193) (expect=3D14920)
Nov 28 15:12:49 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:12:54 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D5377) (expect=3D6007)
Nov 28 15:12:54 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:13:25 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D19948) (expect=3D20409)
Nov 28 15:13:25 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:15:03 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D59989) (expect=3D60513)
Nov 28 15:15:03 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:15:30 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D14866) (expect=3D15700)
Nov 28 15:15:30 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:16:07 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D21605) (expect=3D22301)
Nov 28 15:16:07 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:17:06 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D37936) (expect=3D38825)
Nov 28 15:17:06 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:17:17 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D8070) (expect=3D8518)
Nov 28 15:17:17 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:17:58 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D29990) (expect=3D30458)
Nov 28 15:17:58 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:18:16 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D11266) (expect=3D11986)
Nov 28 15:18:16 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:18:29 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D6203) (expect=3D6652)
Nov 28 15:18:29 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:18:51 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D15253) (expect=3D15919)
Nov 28 15:18:51 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:19:58 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D50322) (expect=3D50860)
Nov 28 15:19:58 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
Nov 28 15:19:59 [kernel] ATL1E 0000:02:00.0: eth0: rx sequence number
error (rx=3D479) (expect=3D927)
Nov 28 15:19:59 [kernel] ATL1E 0000:02:00.0: eth0: NIC Link is Up
<1000 Mbps Full Duplex>
