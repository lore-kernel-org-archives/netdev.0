From: David Schwartz <davids@webmaster.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Thu, 13 Jun 2002 00:21:54 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae9hct$e7k$2@main.gmane.org>
References: <5.1.0.14.2.20020612221925.0283fb18@mira-sjcm-3.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: Ben Greear <greearb@candelatech.com>, <linux-kernel@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: <ltd@cisco.com>, Horst von Brand <vonbrand@inf.utfsm.cl>,
   "David S. Miller" <davem@redhat.com>
In-Reply-To: <5.1.0.14.2.20020612221925.0283fb18@mira-sjcm-3.cisco.com>
List-Id: netdev.vger.kernel.org


>i know of many many folk who use transaction logs from HTTP caches for
>volume-based billing.
>right now, those bills are anywhere between 10% to 25% incorrect.

	You are being paid to deliver packets to their destination, not to drop 
them.

	DS
