From: Trevor Hurst <trev@corp.sgi.com>
Subject: cisco_ipsec w/ 2.4.18-4SGI_XFS_1.1
Date: Sat, 27 Jul 2002 10:12:11 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.SGI.3.94.1020727100610.63470B-100000@shotgun.corp.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org


Has anyone gotten the cisco vpn client 3.5.Rel-k9
to work with 2.4.18 or 2.4.18-sgi-xfs???

I have made some progress but not quite there yet..

Details:

[root@fiend vpnclient]# /etc/init.d/vpnclient_init start
Starting /usr/local/bin/vpnclient:
/lib/modules/2.4.18-4SGI_XFS_1.1/CiscoVPN/cisco_ipsec: unresolved symbol
get_fast_time
/lib/modules/2.4.18-4SGI_XFS_1.1/CiscoVPN/cisco_ipsec: 
Hint: You are trying to load a module without a GPL compatible license
      and it has unresolved symbols.  Contact the module supplier for
      assistance, only they can help you.

Failed (insmod)

Any ideas? 

Thanks!

-- Trev


--
Trevor Hurst
Senior Systems Administrator
DCO Unix Production Systems
Silicon Graphics
Office Ph: 650.933.6144
e-mail: trev@sgi.com
pager: trev_p@pager.sgi.com

--
He who pursues righteousness and love
finds life, prosperity and honor.
