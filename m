From: Ralph Doncaster <ralph@istop.com>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 23:41:07 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0306092333560.7705@ns.istop.com>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092006420.12038@ns.istop.com> <20030609204257.L35799@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092200150.28167@ns.istop.com> <3EE54F4D.50909@candelatech.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3EE54F4D.50909@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 9 Jun 2003, Ben Greear wrote:

> One waring about e1000's, make sure you have active airflow across the NICs
> if you put two together.  Otherwise, buy a dual port NIC...it has a single
> chip and you will have less cooling issues.

I liked how easy the e1000's are to come by; even more so than the 3com
cards.  Intel seems to be grabbing market share by agressive pricing
(bought 4 last week for C$50 ea), so almost every computer equipment
distributor carries the intel cards.

Since I already have the single-port cards, I guess I'll install them with
a couple empty PCI slots between them to help with the cooling.

-Ralph
