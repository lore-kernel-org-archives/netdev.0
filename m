From: Wolfgang Walter <linux@stwm.de>
Subject: GRE with GRO very slow when forwarding starting with 3.14.24
Date: Mon, 24 Nov 2014 17:13:52 +0100
Message-ID: <2340533.MickblD7NF@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stable Kernel <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

starting with 3.14.24 GRE with GRO on is very slow. To be more specific=
:

yyyy <--> GRO_endpoint <-_> .... <--> |eth0<->GRO-endpoint | eth1 |<-> =
xxxx

routing (IPv4) between xxxx and yyyy is very slow when GRO is enabled o=
n eth0=20
and/or eth1 starting with stable kernel 3.14.24

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
