From: jamal <hadi@cyberus.ca>
Subject: Re: Update on e1000 troubles (over-heating!)
Date: Mon, 7 Oct 2002 07:56:59 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210070753400.1861-100000@shell.cyberus.ca>
References: <Pine.LNX.4.10.10210061700000.23945-100000@master.linux-ide.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Greear <greearb@candelatech.com>,
   linux-kernel <linux-kernel@vger.kernel.org>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andre Hedrick <andre@pyxtechnologies.com>
In-Reply-To: <Pine.LNX.4.10.10210061700000.23945-100000@master.linux-ide.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



It does seem like you need a lot of packets over a period of time
to recreate it. So if what you are trying to do can achieve that,
you should reproduce it. How many connections and sessions can you
support? BTW, does iscsi call for a zero-copy receive?

cheers,
jamal
