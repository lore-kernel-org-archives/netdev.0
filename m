From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Sat, 08 Jun 2002 17:51:08 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <adu9eo$rsr$2@main.gmane.org>
References: <20020608170511.B26821@mark.mielke.cc>
	<20020608.160407.101346167.davem@redhat.com>
	<3D029DAF.5040006@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark@mark.mielke.cc, cfriesen@nortelnetworks.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3D029DAF.5040006@candelatech.com>
List-Id: netdev.vger.kernel.org

   From: Ben Greear <greearb@candelatech.com>
   Date: Sat, 08 Jun 2002 17:13:35 -0700
   
   If you're talking per-socket SNMP counters, then that could work.
   General protocol-wide counters would not help much, at least
   in my case.

Why not?  If you know where the drops are occurring, what else
do you need to know?

I'm not talking about per-socket SNMP counters, that would be
rediclious.
