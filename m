From: MANJUNATH <manjunath@ece.iisc.ernet.in>
Subject: iptables
Date: Mon, 29 Nov 2004 20:28:20 +0530 (IST)
Message-ID: <Pine.BSF.4.58.0411292011210.58380@ece.iisc.ernet.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





I am new to linux kernal source,I understand that iptables MASQUERADE
chain inturn makes use of NF_IP_POST_ROUTING HOOK to change src addr, src port
of the outgoing packets.

Is NF_IP_PRE_ROUTING HOOK is used to map public address of the incoming
packets to the local private address ?


Regards
Manjunath
