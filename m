From: "David S. Miller" <davem@redhat.com>
Subject: Re: sctp snmp mib stats in /proc/net/snmp
Date: Tue, 05 Nov 2002 15:34:20 -0800 (PST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20021105.153420.133769117.davem@redhat.com>
References: <20021029.091823.121274899.davem@redhat.com>
	<3DBEC628.75396DA@us.ibm.com>
	<3DC84747.67C80B24@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
Return-path: <linux-net-owner@vger.kernel.org>
To: niv@us.ibm.com
In-Reply-To: <3DC84747.67C80B24@us.ibm.com>
List-Id: netdev.vger.kernel.org

   From: Nivedita Singhvi <niv@us.ibm.com>
   Date: Tue, 05 Nov 2002 14:33:43 -0800
   
   It would be easier to manage this under the sctp subdirectory
   altogether. i.e. We diplay the SCTP SNMP and other extended stats
   as /proc/net/sctp/snmp and /proc/net/sctp/sctp_mib or some such
   name (which would be somewhat dynamic short term). This would also
   solve unnecessary duplication for AF_INET6 for us.

I'm fine with this.
