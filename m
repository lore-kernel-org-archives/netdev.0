From: "David S. Miller" <davem@redhat.com>
Subject: Re: networking bugs and bugme.osdl.org
Date: Sun, 29 Jun 2003 14:15:28 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030629.141528.74734144.davem@redhat.com>
References: <3EFC9203.3090508@candelatech.com>
	<20030627.144426.71096593.davem@redhat.com>
	<1056755070.5463.12.camel@dhcp22.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, mbligh@aracnet.com, linux-kernel@vger.kernel.org,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: alan@lxorguk.ukuu.org.uk
In-Reply-To: <1056755070.5463.12.camel@dhcp22.swansea.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Alan Cox <alan@lxorguk.ukuu.org.uk>
   Date: 28 Jun 2003 00:04:30 +0100
   
   You are assuming there is a relationship in bug severity/commonness
   and number of *developers* who hit it.

Not true, the assumption I make is that a bug report that
a bug reporter cares about, and a patch that a patch submitter
cares about, will all get resent if they get dropped.

If the reporter/submitter doesn't care, neither do I.

You keep saying that lost information is bad and serves no
positive purpose, and I totally disagree.  Drops are litmus tests
for the patch/report, they also serve to educate the submitters.

And to repeat, this process is a two way street Alan.  If you try to
make it anything else, you will wear yourself thin.

Once you enforce the work to be distributed to the people who report
to you as much as to the people taking the reports, thing will go much
more smoothly. :-)
