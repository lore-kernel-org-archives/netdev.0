From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Sun, 23 Jun 2002 03:03:47 +0100 (BST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <af397q$tv7$2@main.gmane.org>
References: <5.1.0.14.2.20020612221925.0283fb18@mira-sjcm-3.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vonbrand@inf.utfsm.cl (Horst von Brand),
   davem@redhat.com (David S. Miller), greearb@candelatech.com (Ben Greear),
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: ltd@cisco.com (Lincoln Dale)
In-Reply-To: <5.1.0.14.2.20020612221925.0283fb18@mira-sjcm-3.cisco.com> from "Lincoln Dale" at Jun 12, 2002 10:28:15 PM
List-Id: netdev.vger.kernel.org

> i know of many many folk who use transaction logs from HTTP caches for 
> volume-based billing.
> right now, those bills are anywhere between 10% to 25% incorrect.
> 
> you call that "extremely limited"?

It wouldnt help you anyway. Prove which frames were not due to the
overloading and congestion/errors on your network which therefore the customer should 
not have a duty to pay. Account for bitstuffing on HDLC links...
