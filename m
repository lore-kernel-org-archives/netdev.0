From: bert hubert <ahu@ds9a.nl>
Subject: interop success, ip6sec Linux 2.5.65 vs FreeBSD 4.7-STABLE
Date: Tue, 18 Mar 2003 17:09:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030318160931.GA9529@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks to Niels Bakker I can report that stock Linux 2.5.65 can talk IP6SEC
with FreeBSD 4.7-STABLE (KAME 20010528/FreeBSD). It worked on the first try.

This using ipsec-tools-0.2.2 and manual keying. Racoon is reported not to
listen on IPv6 sockets yet, but we didn't try this.

The configuration used is that described in
http://lartc.org/howto/lartc.ipsec.html 'Intro with Manual Keying', with
IPv4 addresses replaced by IPv6 addresses.

Thanks for making this possible!

Regards,

Bert

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
http://netherlabs.nl                         Consulting
