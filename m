From: Ralph Doncaster <ralph@istop.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 14:10:32 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0306101402350.16454@ns.istop.com>
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

I just took a closer look at my e1000's.  They've got a small RC82540EM
bga chip on them, manufactured 25th week of '02. If these things do get
hot enough to cause problems why wouldn't Intel have them manufactured
with heatsinks attached?

-Ralph
