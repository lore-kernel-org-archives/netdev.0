From: "David S. Miller" <davem@redhat.com>
Subject: Re: Network oops
Date: Sun, 09 Jun 2002 22:06:21 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020609.220621.82407794.davem@redhat.com>
References: <3D0390E2.1B80ADEE@mvista.com>
	<20020609.213150.32126725.davem@redhat.com>
	<3D042F8F.72764243@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: george@mvista.com
In-Reply-To: <3D042F8F.72764243@mvista.com>
List-Id: netdev.vger.kernel.org

   From: george anzinger <george@mvista.com>
   Date: Sun, 09 Jun 2002 21:48:15 -0700
   
   I would expect that the network code would recover from this
   sort of thing, so we are looking for a preempt issue at the
   moment.  Still, it could just be the way things work in the
   2.4.17 kernel so I thought I would ask.

Even though 2.4.17 is pretty old I still think it's a preempt
problem.
