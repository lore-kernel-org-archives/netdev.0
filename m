From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: networking bugs and bugme.osdl.org
Date: 29 Jun 2003 23:07:07 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1056924426.16255.24.camel@dhcp22.swansea.linux.org.uk>
References: <3EFC9203.3090508@candelatech.com>
	 <20030627.144426.71096593.davem@redhat.com>
	 <1056755070.5463.12.camel@dhcp22.swansea.linux.org.uk>
	 <20030629.141528.74734144.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, mbligh@aracnet.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030629.141528.74734144.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sul, 2003-06-29 at 22:15, David S. Miller wrote:
> You keep saying that lost information is bad and serves no
> positive purpose, and I totally disagree.  Drops are litmus tests
> for the patch/report, they also serve to educate the submitters.

What you don't get is that like you I'm distributing work. I'm getting
end users to spot bug correlations - and thats why I want better tools

Report bug should get
Your bug looks like #1131 #4151 or #11719 (Resolved), please check 
