From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: networking bugs and bugme.osdl.org
Date: 28 Jun 2003 00:04:30 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1056755070.5463.12.camel@dhcp22.swansea.linux.org.uk>
References: <18330000.1056692768@[10.10.2.4]>
	 <20030626.224739.88478624.davem@redhat.com>
	 <3EFC9203.3090508@candelatech.com>
	 <20030627.144426.71096593.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, mbligh@aracnet.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030627.144426.71096593.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Gwe, 2003-06-27 at 22:44, David S. Miller wrote:
> This work for kernel patches, and has so for over 5 years.
> So what makes anyone thing it doesn't work for bug reporting?

It works badly for kernel patches, stuff does get lost forever, missed
etc. Having it all archived somewhere is really valuable because it
means you can spot patterns, trends and also when someone who isnt a
hacker hits the bug *they* can find the patch you missed and send it on
or remind you

You are assuming there is a relationship in bug severity/commonness and
number of *developers* who hit it. That isnt true, developer and end
user hardware patterns are radically different in some areas
