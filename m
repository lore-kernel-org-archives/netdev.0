From: "Umasankar Mukkara" <mumasankar@novell.com>
Subject: IPSEC MIB instrumentatoin ??
Date: Wed, 08 Dec 2004 05:45:35 -0700
Message-ID: <s1b6950e.096@lucius.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

Native ipsec stack lacks proc file instrumentation for IPSEC
statistics. Would a patch for this instrumentation be looked as a good
one?

Following can be the ipsec related counters in ESP4/AH4/
ESP6/AH6/IPCOMP
-Packets Encrypted
-Packets decypted
-Packets discarded (Policy enforcement)
-Replay packets
etc etc.

Or something closer to "draft-ietf-ipsec-monitor-mib-06.txt " which is
an expired draft and can be found at 

http://www.tatsuyababa.com/internet-drafts/draft-ietf-ipsec-monitor-mib-06.txt

- Uma.
