From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Thu, 05 Sep 2002 20:58:42 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020905.205842.127265672.davem@redhat.com>
References: <Pine.GSO.4.30.0209052129580.21731-100000@shell.cyberus.ca>
	<1031283490.3d7823228d9ed@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, tcw@tempest.prismnet.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <1031283490.3d7823228d9ed@imap.linux.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Nivedita Singhvi <niv@us.ibm.com>
   Date: Thu,  5 Sep 2002 20:38:10 -0700

   most recent (dont know how far back) versions of netstat
   display /proc/net/snmp and /proc/net/netstat (with the 
   Linux TCP MIB), so netstat -s should show you most of 
   whats interesting. Or were you referring to something else?
   
   ifconfig -a and netstat -rn would also be nice to have..
   
TSO gets turned off during retransmits/SACK and the card does not do
retransmits.

Can we move on in this conversation now? :-)
