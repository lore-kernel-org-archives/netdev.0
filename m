From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Mon, 10 Jun 2002 05:18:57 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020610.051857.97850707.davem@redhat.com>
References: <3D039D22.2010805@candelatech.com>
	<20020609.213440.04716391.davem@redhat.com>
	<5.1.0.14.2.20020610220015.040aff60@mira-sjcm-3.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, mark@mark.mielke.cc, cfriesen@nortelnetworks.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: ltd@cisco.com
In-Reply-To: <5.1.0.14.2.20020610220015.040aff60@mira-sjcm-3.cisco.com>
List-Id: netdev.vger.kernel.org

   From: Lincoln Dale <ltd@cisco.com>
   Date: Mon, 10 Jun 2002 22:03:25 +1000
   
   would you be willing to accept a patch that enables per-socket
   accounting with a CONFIG_ option?

What is the point?

If all the dists will enable it then everybody eats the overhead.
If the dists don't enable it, how useful is it and what's so wrong
with it being an external patch people just apply when they need to
diagnose something like this?
